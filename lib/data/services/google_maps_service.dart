import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsService {
  static const String _apiKey = 'AIzaSyCSJmPsY5Am1uES-wfoW2Yk5qziMoJohMM';
  static const String _directionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  static const String _geocodeBaseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  static const String _distanceMatrixBaseUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';

  final PolylinePoints _polylinePoints = PolylinePoints();

  /// Get directions from origin to destination
  Future<Map<String, dynamic>?> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    try {
      String waypointsParam = '';
      if (waypoints != null && waypoints.isNotEmpty) {
        waypointsParam = waypoints
            .map((point) => '${point.latitude},${point.longitude}')
            .join('|');
      }

      final url = Uri.parse(_directionsBaseUrl).replace(
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          if (waypointsParam.isNotEmpty) 'waypoints': waypointsParam,
          'key': _apiKey,
          'mode': 'driving',
          'alternatives': 'false',
        },
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          // Extract polyline
          final polylineEncoded = route['overview_polyline']['points'];
          final polylineCoords = _polylinePoints.decodePolyline(polylineEncoded);
          
          // Convert to LatLng list
          final List<LatLng> polylinePoints = polylineCoords
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          return {
            'polylinePoints': polylinePoints,
            'distance': leg['distance']['value'], // in meters
            'distanceText': leg['distance']['text'],
            'duration': leg['duration']['value'], // in seconds
            'durationText': leg['duration']['text'],
            'startAddress': leg['start_address'],
            'endAddress': leg['end_address'],
          };
        }
      }
      
      return null;
    } catch (e) {
      // print('Error getting directions: $e');
      return null;
    }
  }

  /// Get distance and duration between two points
  Future<Map<String, dynamic>?> getDistanceAndDuration({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final url = Uri.parse(_distanceMatrixBaseUrl).replace(
        queryParameters: {
          'origins': '${origin.latitude},${origin.longitude}',
          'destinations': '${destination.latitude},${destination.longitude}',
          'key': _apiKey,
          'mode': 'driving',
        },
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && 
            data['rows'] != null && 
            data['rows'].isNotEmpty &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'].isNotEmpty) {
          
          final element = data['rows'][0]['elements'][0];
          
          if (element['status'] == 'OK') {
            return {
              'distance': element['distance']['value'], // in meters
              'distanceText': element['distance']['text'],
              'duration': element['duration']['value'], // in seconds
              'durationText': element['duration']['text'],
            };
          }
        }
      }
      
      return null;
    } catch (e) {
      // print('Error getting distance and duration: $e');
      return null;
    }
  }

  /// Reverse geocode to get address from coordinates
  Future<String?> getAddressFromCoordinates(LatLng location) async {
    try {
      final url = Uri.parse(_geocodeBaseUrl).replace(
        queryParameters: {
          'latlng': '${location.latitude},${location.longitude}',
          'key': _apiKey,
        },
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && 
            data['results'] != null && 
            data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      
      return null;
    } catch (e) {
      // print('Error getting address: $e');
      return null;
    }
  }

  /// Geocode to get coordinates from address
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final url = Uri.parse(_geocodeBaseUrl).replace(
        queryParameters: {
          'address': address,
          'key': _apiKey,
        },
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && 
            data['results'] != null && 
            data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
      
      return null;
    } catch (e) {
      // print('Error getting coordinates: $e');
      return null;
    }
  }

  /// Format distance from meters
  String formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
  }

  /// Format duration from seconds
  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '$hours hr ${minutes} min';
    } else {
      return '$minutes min';
    }
  }
}
