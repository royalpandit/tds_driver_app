import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mappls_gl/mappls_gl.dart';
import '../../core/constants/api_constants.dart';

class LocationService {
  static const String _userAgent = 'TravelDesk/1.0 (contact@traveldesk.com)';
  static const Duration _atlasTokenRefreshBuffer = Duration(seconds: 60);
  static String? _cachedAtlasToken;
  static DateTime? _cachedAtlasTokenExpiry;

  /// Make an API request to MapMyIndia Atlas Text Search
  Future<List<Map<String, dynamic>>> _atlasTextSearch(String query) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.atlasBaseUrl}${ApiConstants.atlasTextSearchEndpoint}'
      ).replace(queryParameters: {
        'query': query,
        'region': 'ind',
      });

      final token = await _getAtlasAuthToken();
      if (token == null) {
        return [];
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': _userAgent,
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse the response from Atlas - it returns suggestedLocations array
        List suggestedLocations = [];
        
        if (data is Map && data['suggestedLocations'] != null && data['suggestedLocations'] is List) {
          suggestedLocations = data['suggestedLocations'] as List;
        }

        if (suggestedLocations.isNotEmpty) {
          // Process each location and get coordinates if not available
          List<Map<String, dynamic>> results = [];
          for (var item in suggestedLocations) {
            final address = item['placeAddress'] ?? item['address'] ?? '';
            final name = item['placeName'] ?? item['name'] ?? _extractPlaceName(address);
            final type = item['type'] ?? 'UNKNOWN';
            final eLoc = item['eLoc'] ?? '';
            
            // Get coordinates from item or fetch via eLoc
            var lat = item['latitude']?.toString() ?? '';
            var lng = item['longitude']?.toString() ?? '';
            
            // If no direct lat/lng and we have eLoc, try to geocode it
            if ((lat.isEmpty || lng.isEmpty) && eLoc.isNotEmpty) {
              final coords = await _getCoordinatesFromELoc(eLoc);
              if (coords != null) {
                lat = coords['latitude'] ?? '';
                lng = coords['longitude'] ?? '';
              }
            }

            results.add({
              'placeName': name,
              'placeAddress': address,
              'latitude': lat,
              'longitude': lng,
              'eLoc': eLoc,
              'type': type,
              'source': 'atlas',
              'raw': item,
            });
          }
          
          return results;
        }
      }
    } catch (e) {
      // Silent error handling for performance
    }

    return [];
  }

  /// Get coordinates from eLoc (entity location code) using MapMyIndia eLoc API
  Future<Map<String, dynamic>?> _getCoordinatesFromELoc(String eLoc) async {
    if (eLoc.isEmpty) return null;
    
    try {
      final token = await _getAtlasAuthToken();
      if (token == null) return null;

      final url = Uri.parse('https://atlas.mapmyindia.com/api/places/geocode')
        .replace(queryParameters: {'address': eLoc});

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['copResults'] != null && data['copResults'] is Map) {
          final results = data['copResults'];
          return {
            'latitude': results['latitude']?.toString() ?? '',
            'longitude': results['longitude']?.toString() ?? '',
          };
        }
      }
    } catch (e) {
      // Silent error handling
    }
    
    return null;
  }

  Future<String?> _getAtlasAuthToken() async {
    final now = DateTime.now();
    if (_cachedAtlasToken != null &&
        _cachedAtlasTokenExpiry != null &&
        now.isBefore(_cachedAtlasTokenExpiry!)) {
      return _cachedAtlasToken;
    }

    return _refreshAtlasAuthToken();
  }

  Future<String?> _refreshAtlasAuthToken() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.mapplsOAuthTokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'User-Agent': _userAgent,
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': ApiConstants.mapplsClientId,
          'client_secret': ApiConstants.mapplsClientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'] as String?;
        final expiresInValue = data['expires_in'];
        final expiresInSeconds = expiresInValue is int
            ? expiresInValue
            : int.tryParse(expiresInValue?.toString() ?? '');

        if (accessToken != null) {
          final duration = Duration(seconds: expiresInSeconds ?? 3600);
          _cachedAtlasToken = accessToken;
          _cachedAtlasTokenExpiry = DateTime.now()
              .add(duration)
              .subtract(_atlasTokenRefreshBuffer);
          return accessToken;
        }
      }
    } catch (e) {
      // Silent error handling
    }

    return null;
  }

  /// Search for locations using MapMyIndia Atlas Text Search
  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    // Don't call API for very short queries
    if (q.length < 3) {
      return [];
    }

    try {
      // Try Atlas text search
      final atlasResults = await _atlasTextSearch(q);
      if (atlasResults.isNotEmpty) return atlasResults;

      return _getFallbackLocations(q);
    } catch (e) {
      return _getFallbackLocations(q);
    }
  }

  /// Public helper to geocode a full address using MapMyIndia Atlas
  /// Returns first matching result or null
  Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    final res = await _atlasTextSearch(address);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  /// Get fallback locations for common Indian cities
  List<Map<String, dynamic>> _getFallbackLocations(String query) {
    const fallbackLocations = [
      {
        'placeName': 'Mumbai',
        'placeAddress': 'Mumbai, Maharashtra, India',
        'latitude': '19.0760',
        'longitude': '72.8777',
        'source': 'fallback',
      },
      {
        'placeName': 'Delhi',
        'placeAddress': 'Delhi, Delhi, India',
        'latitude': '28.7041',
        'longitude': '77.1025',
        'source': 'fallback',
      },
      {
        'placeName': 'Bangalore',
        'placeAddress': 'Bangalore, Karnataka, India',
        'latitude': '12.9716',
        'longitude': '77.5946',
        'source': 'fallback',
      },
      {
        'placeName': 'Chennai',
        'placeAddress': 'Chennai, Tamil Nadu, India',
        'latitude': '13.0827',
        'longitude': '80.2707',
        'source': 'fallback',
      },
      {
        'placeName': 'Kolkata',
        'placeAddress': 'Kolkata, West Bengal, India',
        'latitude': '22.5726',
        'longitude': '88.3639',
        'source': 'fallback',
      },
      {
        'placeName': 'Pune',
        'placeAddress': 'Pune, Maharashtra, India',
        'latitude': '18.5204',
        'longitude': '73.8567',
        'source': 'fallback',
      },
      {
        'placeName': 'Ahmedabad',
        'placeAddress': 'Ahmedabad, Gujarat, India',
        'latitude': '23.0225',
        'longitude': '72.5714',
        'source': 'fallback',
      },
      {
        'placeName': 'Jaipur',
        'placeAddress': 'Jaipur, Rajasthan, India',
        'latitude': '26.9124',
        'longitude': '75.7873',
        'source': 'fallback',
      },
      {
        'placeName': 'Hyderabad',
        'placeAddress': 'Hyderabad, Telangana, India',
        'latitude': '17.3850',
        'longitude': '78.4867',
        'source': 'fallback',
      },
      {
        'placeName': 'Surat',
        'placeAddress': 'Surat, Gujarat, India',
        'latitude': '21.1702',
        'longitude': '72.8311',
        'source': 'fallback',
      },
    ];

    // Filter locations based on query
    final filteredLocations = fallbackLocations.where((location) {
      final placeName = location['placeName']?.toString().toLowerCase() ?? '';
      final placeAddress = location['placeAddress']?.toString().toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return placeName.contains(queryLower) || placeAddress.contains(queryLower);
    }).toList();

    return filteredLocations.take(5).toList();
  }

  /// Extract a clean place name from address string
  String _extractPlaceName(String address) {
    if (address.isEmpty) return 'Unknown Location';

    // Split by comma and take first meaningful part
    final parts = address.split(',');
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty &&
          !trimmed.contains('India') &&
          !trimmed.contains('IN') &&
          trimmed.length > 2) {
        return trimmed;
      }
    }

    return parts.first.trim();
  }

  /// Validate coordinates
  static bool areValidCoordinates(String lat, String lng) {
    try {
      final latitude = double.parse(lat);
      final longitude = double.parse(lng);
      return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
    } catch (e) {
      return false;
    }
  }

  // ===== Mappls Flutter SDK API Methods =====

  /// Auto Suggest - Intelligent search with autocomplete
  Future<List<Map<String, dynamic>>> autoSuggest(String query, {
    LatLng? location,
    double? zoom,
    bool tokenizeAddress = false,
    String? pod,
    String? filter,
  }) async {
    try {
      final response = await MapplsAutoSuggest(
        query: query,
        location: location,
        zoom: zoom,
        tokenizeAddress: tokenizeAddress,
        pod: pod,
        filter: filter,
      ).callAutoSuggest();

      if (response != null && response.suggestedLocations != null) {
        return response.suggestedLocations!.map((location) => {
          'mapplsPin': location.mapplsPin,
          'placeName': location.placeName,
          'placeAddress': location.placeAddress,
          'type': location.type,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'addressTokens': location.addressTokens?.toJson(),
        }).toList();
      }
      return [];
    } catch (e) {
      print('Auto Suggest error: $e');
      return [];
    }
  }

  /// Geocoding - Convert address to coordinates
  Future<Map<String, dynamic>?> geocode(String address, {
    int itemCount = 1,
    String? podFilter,
    int? bias,
    String? bound,
  }) async {
    try {
      final response = await MapplsGeoCoding(
        address: address,
        itemCount: itemCount,
        podFilter: podFilter,
        bias: bias,
        bound: bound,
      ).callGeocoding();

      if (response != null && response.results != null && response.results!.isNotEmpty) {
        final result = response.results!.first;
        return {
          'latitude': result.latitude,
          'longitude': result.longitude,
          'formattedAddress': result.formattedAddress,
          'houseNumber': result.houseNumber,
          'houseName': result.houseName,
          'poi': result.poi,
          'street': result.street,
          'subSubLocality': result.subSubLocality,
          'subLocality': result.subLocality,
          'locality': result.locality,
          'village': result.village,
          'subDistrict': result.subDistrict,
          'district': result.district,
          'city': result.city,
          'state': result.state,
          'pincode': result.pincode,
        };
      }
      return null;
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  /// Reverse Geocoding - Convert coordinates to address
  Future<Map<String, dynamic>?> reverseGeocode(LatLng location) async {
    try {
      final response = await MapplsReverseGeocode(location: location).callReverseGeocode();

      if (response != null && response.results != null && response.results!.isNotEmpty) {
        final result = response.results!.first;
        return {
          'houseNumber': result.houseNumber,
          'houseName': result.houseName,
          'poi': result.poi,
          'street': result.street,
          'subSubLocality': result.subSubLocality,
          'subLocality': result.subLocality,
          'locality': result.locality,
          'village': result.village,
          'subDistrict': result.subDistrict,
          'district': result.district,
          'city': result.city,
          'state': result.state,
          'pincode': result.pincode,
          'formattedAddress': result.formattedAddress,
        };
      }
      return null;
    } catch (e) {
      print('Reverse Geocoding error: $e');
      return null;
    }
  }

  /// Nearby Places - Find places around a location
  Future<List<Map<String, dynamic>>> nearbyPlaces({
    required String keyword,
    required LatLng location,
    int? radius,
    String? bounds,
    String? userName,
    bool richData = false,
    String? pod,
    String? filter,
    int? page,
  }) async {
    try {
      final response = await MapplsNearby(
        keyword: keyword,
        location: location,
        radius: radius,
        bounds: bounds,
        userName: userName,
        richData: richData,
        pod: pod,
        filter: filter,
        page: page,
      ).callNearby();

      if (response != null && response.suggestedLocations != null) {
        return response.suggestedLocations!.map((place) => {
          'mapplsPin': place.mapplsPin,
          'placeName': place.placeName,
          'placeAddress': place.placeAddress,
          'distance': place.distance,
          'latitude': place.latitude,
          'longitude': place.longitude,
          'type': place.type,
          'keywords': place.keywords,
          'email': place.email,
          'landlineNo': place.landlineNo,
          'mobileNo': place.mobileNo,
          'richInfo': place.richInfo,
          'hourOfOperation': place.hourOfOperation,
          'addressTokens': place.addressTokens?.toJson(),
        }).toList();
      }
      return [];
    } catch (e) {
      print('Nearby Places error: $e');
      return [];
    }
  }

  /// Place Details - Get detailed information about a place
  Future<Map<String, dynamic>?> placeDetails(String mapplsPin) async {
    try {
      final response = await MapplsPlaceDetail(mapplsPin: mapplsPin).callPlaceDetail();

      if (response != null) {
        return {
          'mapplsPin': response.mapplsPin,
          'placeName': response.placeName,
          'address': response.address,
          'type': response.type,
          // Add other fields as needed based on sub-templates
        };
      }
      return null;
    } catch (e) {
      print('Place Details error: $e');
      return null;
    }
  }

  /// POI Along Route - Find POIs along a route
  Future<List<Map<String, dynamic>>> poiAlongRoute({
    required String path,
    required String category,
    int buffer = 25,
    String geometries = 'polyline6',
    int? page,
  }) async {
    try {
      final response = await MapplsPOIAlongRoute(
        path: path,
        category: category,
        buffer: buffer,
        geometries: geometries,
        page: page,
      ).callPOIAlongRoute();

      if (response != null && response.suggestedPOIs != null) {
        return response.suggestedPOIs!.map((poi) => {
          'distance': poi.distance,
          'mapplsPin': poi.mapplsPin,
          'poi': poi.poi,
          'subSubLocality': poi.subSubLocality,
          'subLocality': poi.subLocality,
          'locality': poi.locality,
          'city': poi.city,
          'subDistrict': poi.subDistrict,
          'district': poi.district,
          'state': poi.state,
          'popularName': poi.popularName,
          'address': poi.address,
          'telephoneNumber': poi.telephoneNumber,
          'email': poi.email,
          'website': poi.website,
          'longitude': poi.longitude,
          'latitude': poi.latitude,
          'entryLongitude': poi.entryLongitude,
          'entryLatitude': poi.entryLatitude,
          'brandCode': poi.brandCode,
        }).toList();
      }
      return [];
    } catch (e) {
      print('POI Along Route error: $e');
      return [];
    }
  }
}



