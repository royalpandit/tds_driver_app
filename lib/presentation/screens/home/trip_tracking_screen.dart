import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
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
        _showPermissionDeniedDialog();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // print('Error getting current location: $e');
    }
  }

  Future<void> _drawRouteAndMarkers() async {
    if (_currentLocation == null || _pickupLocation == null || _dropLocation == null) {
      return;
    }

    // Clear existing markers and polylines
    _markers.clear();
    _polylines.clear();

    // Add markers
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('pickup_location'),
        position: _pickupLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Pickup',
          snippet: widget.tripDetails.rideRequest.pickupAddress,
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('drop_location'),
        position: _dropLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Drop-off',
          snippet: widget.tripDetails.rideRequest.dropAddress,
        ),
      ),
    );

    // Get directions from current location to pickup, then to drop
    final directionsToPickup = await _mapsService.getDirections(
      origin: _currentLocation!,
      destination: _pickupLocation!,
    );

    final directionsToDropoff = await _mapsService.getDirections(
      origin: _pickupLocation!,
      destination: _dropLocation!,
    );

    // Draw route to pickup
    if (directionsToPickup != null) {
      final polylinePoints = directionsToPickup['polylinePoints'] as List<LatLng>;
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_pickup'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );

      setState(() {
        _distanceText = directionsToPickup['distanceText'];
        _durationText = directionsToPickup['durationText'];
      });
    }

    // Draw route from pickup to dropoff (in different color)
    if (directionsToDropoff != null) {
      final polylinePoints = directionsToDropoff['polylinePoints'] as List<LatLng>;
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_dropoff'),
          points: polylinePoints,
          color: Colors.green,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );

      final totalDistance = (directionsToPickup?['distance'] ?? 0) +
          directionsToDropoff['distance'];
      setState(() {
        _totalDistanceText = _mapsService.formatDistance(totalDistance);
      });
    }

    // Fit bounds to show all markers
    if (_mapController != null) {
      _fitBoundsToMarkers();
    }

    setState(() {});
  }

  void _fitBoundsToMarkers() {
    if (_markers.isEmpty || _mapController == null) return;

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

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  void _startLocationTracking() {
    // Update location every 10 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newLocation;

        // Update current location marker
        _markers.removeWhere((m) => m.markerId.value == 'current_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: newLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      });

      // Update route
      _drawRouteAndMarkers();
    });
  }

  Future<void> _updateCurrentLocationOnServer() async {
    if (_currentLocation == null) return;

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
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Trip Tracking',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Trip Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(
                            Icons.directions_car,
                            'Distance to Pickup',
                            _distanceText,
                          ),
                          _buildInfoItem(
                            Icons.access_time,
                            'Time to Pickup',
                            _durationText,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(
                            Icons.route,
                            'Total Trip Distance',
                            _totalDistanceText,
                          ),
                          _buildInfoItem(
                            Icons.person,
                            'Trip ID',
                            '#${widget.tripId}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Map
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation ?? const LatLng(23.0225, 72.5714),
                      zoom: 14,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _fitBoundsToMarkers();
                    },
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    mapType: MapType.normal,
                  ),
                ),
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _recenterMap,
                          icon: const Icon(Icons.my_location),
                          label: Text(
                            'Recenter',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _refreshRoute,
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            'Refresh Route',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.lightPrimary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
      ),
    );
  }

  void _recenterMap() {
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    }
  }

  void _refreshRoute() {
    setState(() => _isLoading = true);
    _drawRouteAndMarkers().then((_) {
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
