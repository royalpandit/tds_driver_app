import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:traveldesk_driver/data/models/trip_details_response_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:traveldesk_driver/core/utils/string_utils.dart';
import 'dart:typed_data';
import 'package:signature/signature.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../providers/driver_provider.dart';
import '../../../data/services/google_maps_service.dart';
import 'package:image_picker/image_picker.dart';
import 'trip_tracking_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final int tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickupLatLng;
  LatLng? _dropLatLng;
  final GoogleMapsService _mapsService = GoogleMapsService();
  bool _isMapLoading = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late SignatureController _signatureController;
  final List<Uint8List> _uploadedSignatures = [];
  final Set<int> _passengersWithSignatures = {}; // Track which passengers have signatures

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTripDetails();
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _loadTripDetails() async {
    await Provider.of<DriverProvider>(
      context,
      listen: false,
    ).getTripDetails(widget.tripId);

    // Load map coordinates after getting trip details
    if (mounted) {
      await _loadMapCoordinates();
    }
  }

  Future<void> _loadMapCoordinates() async {
    final provider = Provider.of<DriverProvider>(context, listen: false);
    if (provider.tripDetails == null) return;

    setState(() => _isMapLoading = true);

    final rideRequest = provider.tripDetails!.rideRequest;

    // Get pickup coordinates
    if (rideRequest.pickupLat != null && rideRequest.pickupLng != null &&
        rideRequest.pickupLat != 0.0 && rideRequest.pickupLng != 0.0) {
      _pickupLatLng = LatLng(rideRequest.pickupLat!, rideRequest.pickupLng!);
    } else if (rideRequest.pickupAddress.isNotEmpty) {
      _pickupLatLng = await _mapsService.getCoordinatesFromAddress(
        rideRequest.pickupAddress,
      );
    }

    // Get drop coordinates
    if (rideRequest.dropLat != null && rideRequest.dropLng != null &&
        rideRequest.dropLat != 0.0 && rideRequest.dropLng != 0.0) {
      _dropLatLng = LatLng(rideRequest.dropLat!, rideRequest.dropLng!);
    } else if (rideRequest.dropAddress.isNotEmpty) {
      _dropLatLng = await _mapsService.getCoordinatesFromAddress(
        rideRequest.dropAddress,
      );
    }

    // Fallback: use India center if geocoding fails
    _pickupLatLng ??= const LatLng(20.5937, 78.9629);
    _dropLatLng ??= const LatLng(20.5937, 78.9629);
    debugPrint("Pickup LAT LNG => $_pickupLatLng");
    debugPrint("Drop LAT LNG => $_dropLatLng");
    // Draw markers and route after loading coordinates
    if (mounted) {
      await _prepareMapData();
     // _prepareMapData();
    }
    if (mounted) {
      setState(() => _isMapLoading = false);
    }
    //setState(() => _isMapLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Trip Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<DriverProvider>(
        builder: (context, provider, child) {

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tripDetails == null) {
            return const Center(child: Text("No trip details available"));
          }

          final details = provider.tripDetails!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                child!, // ⭐ MAP अब rebuild नहीं होगा

                const SizedBox(height: 16),

                _buildPassengerList(details, details.trip.status),
                const SizedBox(height: 16),
                _buildTripInfo(details),
                // Show Map button for running/started trips
                if (details.trip.status.toLowerCase() == 'running' ||
                    details.trip.status.toLowerCase() == 'in_progress' ||
                    details.trip.status.toLowerCase() == 'started') ...[                  
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToMap(details),
                      icon: const Icon(Icons.map),
                      label: Text(
                        'Show Map',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },

        // ⭐ THIS IS THE FIX
        child: _buildMapSectionStatic(),
      ),

      // body: Consumer<DriverProvider>(
      //   builder: (context, provider, child) {
      //     if (provider.isLoading) {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //     if (provider.errorMessage != null) {
      //       return Center(child: Text(provider.errorMessage!));
      //     }
      //     if (provider.tripDetails == null) {
      //       return const Center(child: Text("No trip details available"));
      //     }
      //     final TripDetailsResponseModel details = provider.tripDetails!;
      //     return SingleChildScrollView(
      //       padding: const EdgeInsets.all(16),
      //       child: Column(
      //         children: [
      //           _buildMapSection(details),
      //           const SizedBox(height: 16),
      //
      //           _buildPassengerList(details, details.trip.status),
      //           const SizedBox(height: 16),
      //           _buildTripInfo(details),
      //         ],
      //       ),
      //     );
      //   },
      // ),
    );
  }

  // ================= TRIP INFO =================
  Widget _buildMapSectionStatic() {
    if (_isMapLoading || _pickupLatLng == null || _dropLatLng == null) {
      return Container(
        height: 260,
        decoration: _cardDecoration(),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: 260,
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          key: const ValueKey("AIzaSyCSJmPsY5Am1uES-wfoW2Yk5qziMoJohMM"),
          initialCameraPosition: CameraPosition(
            target: _pickupLatLng!,
            zoom: 12,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            Future.delayed(const Duration(milliseconds: 300), () {
              _fitBoundsToMarkers();
            });
          },
          markers: _markers,
          polylines: _polylines,

          //  IMPORTANT
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  Widget _buildTripInfo(TripDetailsResponseModel details) {
    final ride = details.rideRequest;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Request Type", StringUtils.formatRequestType(ride.requestType)),
          _infoRow("Trip Category", StringUtils.toTitleCase(ride.tripCategory)),

          _infoRow("Pickup", StringUtils.toTitleCase(ride.pickupAddress)),
          _infoRow("Drop", StringUtils.toTitleCase(ride.dropAddress)),

          _infoRow("Date", app_date_utils.AppDateUtils.formatDate(ride.rideDate)),
          _infoRow("Time", ride.rideTime),

          _infoRow("Estimated KM", "${ride.estimatedKm} km"),
          _infoRow("Estimated Minutes", "${ride.estimatedMins} mins"),

          _infoRow("Status", StringUtils.toTitleCase(details.trip.status)),

          const Divider(height: 25),

          _infoRow("Vehicle", StringUtils.toTitleCase(details.trip.vehicle.model)),
          _infoRow("Driver", StringUtils.toTitleCase(details.trip.driver.name)),
          const SizedBox(height: 12),
          // Show download invoice button only if request type is not roster_auto or corporate
          if (ride.requestType != 'roster_auto' && ride.requestType != 'corporate' && details.trip.status.toLowerCase() == 'completed')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final provider = Provider.of<DriverProvider>(
                        context,
                        listen: false,
                      );
                      try {
                        final result = await provider.downloadInvoice(
                          details.trip.id,
                        );
                        if (result == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Unable to download invoice'),
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invoice opened: $result')),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Invoice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
          children: [
            TextSpan(
              text: "$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // ================= MAP =================

  Future<void> _prepareMapData() async {
    _markers.clear(); //  ADD
    _polylines.clear();
    if (_pickupLatLng == null || _dropLatLng == null) return;

    // Add pickup marker
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'Pickup Location',
          snippet: 'Trip starts here',
        ),
      ),
    );

    // Add drop marker
    _markers.add(
      Marker(
        markerId: const MarkerId('drop'),
        position: _dropLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Drop Location',
          snippet: 'Trip ends here',
        ),
      ),
    );

    if (mounted) {
      setState(() {}); //  MUST
    }
    // Get route between pickup and drop
    final directions = await _mapsService.getDirections(
      origin: _pickupLatLng!,
      destination: _dropLatLng!,
    );

    if (directions != null && directions['polylinePoints'] != null) {
      final polylinePoints = directions['polylinePoints'] as List<LatLng>;
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylinePoints,
          color: AppColors.lightPrimary,
          width: 5,
        ),
      );

      if (mounted) {
        setState(() {}); //  THIS LINE ADD
      }
      // _polylines.add(
      //   Polyline(
      //     polylineId: const PolylineId('route'),
      //     points: polylinePoints,
      //     color: AppColors.lightPrimary,
      //     width: 5,
      //   ),
      // );
    }
    debugPrint("Markers count => ${_markers.length}");
  }

  void _fitBoundsToMarkers() {
    if (!mounted ||
        _mapController == null ||
        _pickupLatLng == null ||
        _dropLatLng == null) {
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        _pickupLatLng!.latitude < _dropLatLng!.latitude
            ? _pickupLatLng!.latitude
            : _dropLatLng!.latitude,
        _pickupLatLng!.longitude < _dropLatLng!.longitude
            ? _pickupLatLng!.longitude
            : _dropLatLng!.longitude,
      ),
      northeast: LatLng(
        _pickupLatLng!.latitude > _dropLatLng!.latitude
            ? _pickupLatLng!.latitude
            : _dropLatLng!.latitude,
        _pickupLatLng!.longitude > _dropLatLng!.longitude
            ? _pickupLatLng!.longitude
            : _dropLatLng!.longitude,
      ),
    );

    try {
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (e) {
      debugPrint('Error fitting bounds: $e');
    }
  }

  // ================= PASSENGER LIST =================

  Widget _buildPassengerList(
    TripDetailsResponseModel details,
    String tripStatus,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Passenger Manifest (${details.trip.passengers.length})",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...details.trip.passengers.map((p) => _passengerRow(p, tripStatus)),
        ],
      ),
    );
  }

  Widget _passengerRow(PassengerModel passenger, String tripStatus) {
    final showActions =
        passenger.status.toLowerCase() == 'waiting' && tripStatus.toLowerCase() != 'completed';
    final isPickedUp = passenger.status.toLowerCase() == 'picked_up' && tripStatus.toLowerCase() != 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Passenger name, status, and signature icon
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StringUtils.toTitleCase(passenger.name),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      StringUtils.toTitleCase(passenger.status),
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Signature icon - show only if picked_up and trip not completed
              if (isPickedUp) ...[
                if (_passengersWithSignatures.contains(passenger.id))
                  const Icon(Icons.check_circle, color: Colors.green, size: 24)
                else
                  GestureDetector(
                    onTap: () => _showSignatureBottomSheet(passenger.id),
                    child: Icon(Icons.edit, color: Colors.orange, size: 24),
                  ),
              ]
            ],
          ),

          // Action buttons below
          if (showActions) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _showOtpDialog(passenger.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Verify", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => _showCancelPassengerDialog(passenger.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ================= OTP POPUP =================

  void _showOtpDialog(int passengerId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Enter OTP"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(hintText: "Enter 6 digit OTP"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _verifyOtp(passengerId, controller.text);
              },
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }

  void _verifyOtp(int passengerId, String otp) async {
    final provider = Provider.of<DriverProvider>(context, listen: false);

    if (provider.tripDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Trip details not available",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = await provider.verifyOtp(
        widget.tripId,
        otp,
        passengerId: passengerId,
        rideRequestId: provider.tripDetails!.rideRequest.id,
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "OTP Verified Successfully",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // 🔄 Refresh trip details to update passenger status
        await provider.getTripDetails(widget.tripId, forceRefresh: true);

        // Open signature bottom sheet so driver can collect passenger signature
        // (API upload call is commented out below; replace with real upload)
        if (mounted) {
          _showSignatureBottomSheet(passengerId);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? "OTP verification failed",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString()}",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSignatureBottomSheet(int passengerId) {
    // Only show if not already collected
    if (_passengersWithSignatures.contains(passengerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signature already collected for this passenger')),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Collect Passenger Signature', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _signatureController.clear();
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _signatureController.clear();
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Dismiss'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        // export signature as PNG bytes
                        final data = await _signatureController.toPngBytes();
                        if (data == null || data.isEmpty) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please provide a signature before submitting')),
                            );
                          }
                          return;
                        }

                        // Call provider to upload signature
                        final provider = Provider.of<DriverProvider>(context, listen: false);
                        final success = await provider.uploadPassengerSignature(
                          tripId: widget.tripId,
                          passengerId: passengerId,
                          userId: passengerId,
                          signaturePngBytes: data,
                        );

                        if (success) {
                          // keep a local copy as well
                          _uploadedSignatures.add(data);
                          // Mark passenger as having signature
                          setState(() {
                            _passengersWithSignatures.add(passengerId);
                          });
                          if (mounted) {
                            Navigator.of(context).pop();
                            _signatureController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Signature uploaded successfully')),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.errorMessage ?? 'Upload failed')),
                            );
                          }
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ================= CANCEL PASSENGER (NO SHOW - No OTP required) =================

  void _showCancelPassengerDialog(int passengerId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Cancel Passenger"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Mark this passenger as no-show? Enter the cancellation reason below.",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: "Enter cancellation reason",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please enter a cancellation reason',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _cancelPassenger(passengerId, reason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Cancel Passenger"),
            ),
          ],
        );
      },
    );
  }

  void _cancelPassenger(int passengerId, String reason) async {
    final provider = Provider.of<DriverProvider>(context, listen: false);

    if (provider.tripDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Trip details not available",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = await provider.cancelPassengerNoShow(
        tripId: widget.tripId,
        passengerId: passengerId,
        cancelReason: reason,
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Passenger cancelled successfully",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        await provider.getTripDetails(widget.tripId, forceRefresh: true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? "Cancellation failed",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString()}",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ================= NAVIGATE TO MAP =================

  void _navigateToMap(TripDetailsResponseModel details) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripTrackingScreen(
          tripId: widget.tripId,
          tripDetails: details,
        ),
      ),
    );
  }

  // ================= COMMON =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
