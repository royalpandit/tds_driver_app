import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:traveldesk_driver/data/models/trip_details_response_model.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/driver_provider.dart';
import 'package:mappls_gl/mappls_gl.dart';



class TripDetailsScreen extends StatefulWidget {
  final int tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  MapplsMapController? _mapController;
  LatLng? _pickupLatLng;
  LatLng? _dropLatLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(
        context,
        listen: false,
      ).getTripDetails(widget.tripId);

    });
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

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.tripDetails == null) {
            return const Center(child: Text("No trip details available"));
          }

          final TripDetailsResponseModel details = provider.tripDetails!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [


                _buildMapSection(details),
                const SizedBox(height: 16),


                _buildPassengerList(details),
                const SizedBox(height: 16),
                _buildTripInfo(details),

              ],
            ),
          );
        },
      ),
    );
  }

  // ================= TRIP INFO =================

  Widget _buildTripInfo(TripDetailsResponseModel details) {
    final ride = details.rideRequest;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _infoRow("Request Type", ride.requestType),
          _infoRow("Trip Category", ride.tripCategory),

          _infoRow("Pickup", ride.pickupAddress),
          _infoRow("Drop", ride.dropAddress),

          _infoRow("Date", ride.rideDate),
          _infoRow("Time", ride.rideTime),

          _infoRow("Estimated KM", "${ride.estimatedKm} km"),
          _infoRow("Estimated Minutes", "${ride.estimatedMins} mins"),

          _infoRow("Status", ride.status),

          const Divider(height: 25),

          _infoRow("Vehicle", details.trip.vehicle.model),
          _infoRow("Driver", details.trip.driver.name),
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

  Widget _buildMapSection(TripDetailsResponseModel details) {

    // TEMP: API me lat/lng nahi aaye to fallback (later API se real coords lena)
    // Agar tumhare model me lat/lng ho to direct use karo

    _pickupLatLng ??= const LatLng(23.0225, 72.5714); // Gandhinagar
    _dropLatLng ??= const LatLng(22.9916, 72.4927);   // Ahmedabad

    return Container(
      height: 260,
      width: double.infinity,
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
       child:MapplsMap(
          initialCameraPosition: CameraPosition(
            target: _pickupLatLng!,
            zoom: 12,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _drawRoute();
          },
          myLocationEnabled: true,
         ),
      ),
    );
  }

  // ================= PASSENGER LIST =================
  void _drawRoute() async {

    if (_mapController == null ||
        _pickupLatLng == null ||
        _dropLatLng == null) return;

    // 📍 Pickup marker
    await _mapController!.addSymbol(
      SymbolOptions(
        geometry: _pickupLatLng!,
        textField: "Pickup",
        textOffset: const Offset(0, 1.5),
      ),
    );

    // 📍 Drop marker
    await _mapController!.addSymbol(
      SymbolOptions(
        geometry: _dropLatLng!,
        textField: "Drop",
        textOffset: const Offset(0, 1.5),
      ),
    );

    // 🛣 Simple route line
    await _mapController!.addLine(
      LineOptions(
        geometry: [
          _pickupLatLng!,
          _dropLatLng!,
        ],
        lineColor: "#1C5479",
        lineWidth: 5,
      ),
    );

    // 🎥 Camera fit
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
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
        ),
        left: 40,
        right: 40,
        top: 40,
        bottom: 40,
      ),
    );
  }

  Widget _buildPassengerList(TripDetailsResponseModel details) {
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

          ...details.trip.passengers.map((p) => _passengerRow(p)),
        ],
      ),
    );
  }

  Widget _passengerRow(PassengerModel passenger) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    passenger.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    passenger.status,
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () => _showOtpDialog(passenger.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text("Verify"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            decoration: const InputDecoration(
              hintText: "Enter 6 digit OTP",
            ),
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

    final provider = Provider.of<DriverProvider>(
      context,
      listen: false,
    );

    if (provider.tripDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Trip details not available"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await provider.verifyOtp(
      widget.tripId,
      otp,
      passengerId: passengerId,
      rideRequestId: provider.tripDetails!.rideRequest.id,
    );

    if (result != null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP Verified Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      // 🔄 Refresh trip details to update passenger status
      provider.getTripDetails(widget.tripId);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP verification failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= COMMON =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
