import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip_details_response_model.dart';
import '../../../data/services/google_maps_service.dart';
import '../../../data/services/api_service.dart';
import '../../providers/driver_provider.dart';

class TripTrackingScreen extends StatefulWidget {
  final int tripId;
  final TripDetailsResponseModel tripDetails;

  const TripTrackingScreen({
    super.key,
    required this.tripId,
    required this.tripDetails,
  });

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  GoogleMapController? _mapController;
  final GoogleMapsService _mapsService = GoogleMapsService();
  final ApiService _apiService = ApiService();

  // Map state
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _dropLocation;

  // Trip data
  String _distanceText = 'Calculating...';
  String _durationText = 'Calculating...';
  String _totalDistanceText = '0 km';
  bool _isLoading = true;
  List<LatLng> _traveledPath = []; // Track where driver has been
  bool _hasReachedPickup = false; // Track if driver reached pickup

  // Location tracking
  Timer? _locationUpdateTimer;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);

    // Get pickup and drop locations from trip details
    final rideRequest = widget.tripDetails.rideRequest;
    
    // If lat/lng are available, use them; otherwise geocode the addresses
    if (rideRequest.pickupLat != null && rideRequest.pickupLng != null) {
      _pickupLocation = LatLng(rideRequest.pickupLat!, rideRequest.pickupLng!);
    } else {
      // Geocode pickup address
      _pickupLocation = await _mapsService.getCoordinatesFromAddress(
        rideRequest.pickupAddress,
      );
    }

    if (rideRequest.dropLat != null && rideRequest.dropLng != null) {
      _dropLocation = LatLng(rideRequest.dropLat!, rideRequest.dropLng!);
    } else {
      // Geocode drop address
      _dropLocation = await _mapsService.getCoordinatesFromAddress(
        rideRequest.dropAddress,
      );
    }

    // Fallback to default coordinates if geocoding fails
    _pickupLocation ??= const LatLng(23.0225, 72.5714); // Gandhinagar
    _dropLocation ??= const LatLng(22.9916, 72.4927); // Ahmedabad

    // Get current location
    await _getCurrentLocation();

    // Draw route and markers
    await _drawRouteAndMarkers();

    // Start location tracking
    _startLocationTracking();

    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      // print('Error getting current location: $e');
    }
  }

  Future<void> _drawRouteAndMarkers() async {
    if (!mounted || _currentLocation == null || _pickupLocation == null || _dropLocation == null) {
      return;
    }

    // Clear existing markers and polylines
    _markers.clear();
    _polylines.clear();

    // Add current location marker (driver)
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location', snippet: 'Current position'),
        anchor: const Offset(0.5, 0.5),
      ),
    );

    // Determine next destination based on trip progress
    LatLng nextDestination;
    String destinationLabel;
    BitmapDescriptor destinationIcon;
    
    if (!_hasReachedPickup) {
      // Driver hasn't reached pickup yet - show route to pickup
      nextDestination = _pickupLocation!;
      destinationLabel = 'Pickup';
      destinationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      
      // Add pickup marker
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup_location'),
          position: _pickupLocation!,
          icon: destinationIcon,
          infoWindow: InfoWindow(
            title: 'Pickup Point',
            snippet: widget.tripDetails.rideRequest.pickupAddress,
          ),
        ),
      );
      
      // Also show drop location (but grayed out)
      _markers.add(
        Marker(
          markerId: const MarkerId('drop_location'),
          position: _dropLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          alpha: 0.5,
          infoWindow: InfoWindow(
            title: 'Drop Point (Next)',
            snippet: widget.tripDetails.rideRequest.dropAddress,
          ),
        ),
      );
    } else {
      // Driver has reached pickup - show route to drop
      nextDestination = _dropLocation!;
      destinationLabel = 'Drop';
      destinationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      
      // Add drop marker
      _markers.add(
        Marker(
          markerId: const MarkerId('drop_location'),
          position: _dropLocation!,
          icon: destinationIcon,
          infoWindow: InfoWindow(
            title: 'Drop Point',
            snippet: widget.tripDetails.rideRequest.dropAddress,
          ),
        ),
      );
      
      // Show pickup as completed (grayed out)
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup_location'),
          position: _pickupLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          alpha: 0.4,
          infoWindow: const InfoWindow(
            title: 'Pickup (Completed)',
          ),
        ),
      );
    }

    // Draw traveled path (where driver has been)
    if (_traveledPath.length > 1) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('traveled_path'),
          points: _traveledPath,
          color: Colors.grey,
          width: 4,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
      );
    }

    // Get directions from current location to next destination
    final directions = await _mapsService.getDirections(
      origin: _currentLocation!,
      destination: nextDestination,
    );

    if (!mounted) return;

    // Draw route to next destination
    if (directions != null) {
      final polylinePoints = directions['polylinePoints'] as List<LatLng>;
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_ahead'),
          points: polylinePoints,
          color: _hasReachedPickup ? Colors.red : Colors.blue,
          width: 5,
        ),
      );

      if (mounted) {
        setState(() {
          _distanceText = directions['distanceText'];
          _durationText = directions['durationText'];
        });
      }
    }

    // Calculate total distance if not reached pickup yet
    if (!_hasReachedPickup) {
      final directionsToDropoff = await _mapsService.getDirections(
        origin: _pickupLocation!,
        destination: _dropLocation!,
      );

      if (directionsToDropoff != null) {
        final totalDistance = (directions?['distance'] ?? 0) +
            directionsToDropoff['distance'];
        if (mounted) {
          setState(() {
            _totalDistanceText = _mapsService.formatDistance(totalDistance);
          });
        }
      }
    } else {
      // After pickup, total distance is just to drop
      if (mounted && directions != null) {
        setState(() {
          _totalDistanceText = directions['distanceText'];
        });
      }
    }

    // Fit bounds to show all markers
    if (mounted && _mapController != null) {
      _fitBoundsToMarkers();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _fitBoundsToMarkers() {
    if (!mounted || _markers.isEmpty || _mapController == null) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var marker in _markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } catch (e) {
      // Controller might be disposed
      print('Error animating camera: $e');
    }
  }

  void _startLocationTracking() {
    // Update location every 10 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateCurrentLocationOnServer();
    });

    // Listen to location changes
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (!mounted) return;
      
      final newLocation = LatLng(position.latitude, position.longitude);

      // Add to traveled path
      _traveledPath.add(newLocation);

      // Check if reached pickup (within 50 meters)
      if (!_hasReachedPickup && _pickupLocation != null) {
        final distanceToPickup = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _pickupLocation!.latitude,
          _pickupLocation!.longitude,
        );
        
        if (distanceToPickup < 50) {
          _hasReachedPickup = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pickup location reached!',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      setState(() {
        _currentLocation = newLocation;
      });

      // Update route with new location
      _drawRouteAndMarkers();
    });
  }

  Future<void> _updateCurrentLocationOnServer() async {
    if (!mounted || _currentLocation == null) return;

    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      final driverId = driverProvider.driverDetails?.personalInfo.id;

      if (driverId == null) return;

      // Get address from coordinates
      final address = await _mapsService.getAddressFromCoordinates(_currentLocation!);

      await _apiService.updateDriverLocation(
        driverId: driverId,
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        address: address,
      );

      // print('✅ Location updated on server');
    } catch (e) {
      // print('❌ Error updating location on server: $e');
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Location Permission Required',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Please enable location permissions to track your trip.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1C5479), Color(0xFF2E8BC0), Color(0xFF4A90E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1C5479), Color(0xFF2E8BC0), Color(0xFF4A90E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Custom Header
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Live Trip Tracking',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Trip #${widget.tripId}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _hasReachedPickup 
                                      ? Colors.orange.shade600
                                      : Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _hasReachedPickup ? Icons.local_shipping : Icons.location_on,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _hasReachedPickup ? 'To Drop' : 'To Pickup',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          
                          // Trip Stats Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildInfoItem(
                                        Ionicons.navigate_circle,
                                        'Distance',
                                        _distanceText,
                                        AppColors.lightPrimary,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Colors.grey.shade300,
                                      ),
                                      _buildInfoItem(
                                        Ionicons.time,
                                        'ETA',
                                        _durationText,
                                        Colors.orange.shade600,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Colors.grey.shade300,
                                      ),
                                      _buildInfoItem(
                                        Ionicons.speedometer,
                                        'Total',
                                        _totalDistanceText,
                                        Colors.green.shade600,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightPrimary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Ionicons.people, size: 18, color: AppColors.lightPrimary),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${widget.tripDetails.trip.passengers.length} Passenger${widget.tripDetails.trip.passengers.length > 1 ? 's' : ''}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.lightPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Map Container
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _currentLocation ?? const LatLng(23.0225, 72.5714),
                                      zoom: 14,
                                    ),
                                    onMapCreated: (controller) {
                                      if (!mounted) return;
                                      _mapController = controller;
                                      _fitBoundsToMarkers();
                                    },
                                    markers: _markers,
                                    polylines: _polylines,
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    mapType: MapType.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                if (!_hasReachedPickup) ...[
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _hasReachedPickup = true;
                                        });
                                        _drawRouteAndMarkers();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Pickup completed! Now heading to drop',
                                              style: GoogleFonts.poppins(color: Colors.white),
                                            ),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Ionicons.checkmark_circle, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Reached Pickup',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _recenterMap,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.lightPrimary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: const Icon(Ionicons.locate, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _refreshRoute,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: const Icon(Ionicons.refresh, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _recenterMap() {
    if (!mounted || _currentLocation == null || _mapController == null) return;
    
    try {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    } catch (e) {
      print('Error recentering map: $e');
    }
  }

  void _refreshRoute() {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    _drawRouteAndMarkers().then((_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Route refreshed',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
