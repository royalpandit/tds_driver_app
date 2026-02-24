import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:traveldesk_driver/presentation/screens/home/trip_details_screen.dart';

import '../../widgets/floating_bottom_nav.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../data/models/trip_model.dart';
import '../../../data/models/trip_details_response_model.dart';
import '../../providers/driver_provider.dart';
import 'home_screen.dart';
import 'trip_tracking_screen.dart';

class AllTripsScreen extends StatefulWidget {
  const AllTripsScreen({super.key});

  @override
  State<AllTripsScreen> createState() => _AllTripsScreenState();
}

class _AllTripsScreenState extends State<AllTripsScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';

  // track which trip type tab is selected
  late TabController _tripTypeTabController;
  final List<String> _tripTypeTabs = ['All', 'Round', 'Normal'];
  String _selectedTripType = 'All';

  @override
  void initState() {
    super.initState();
    try {
      _tripTypeTabController = TabController(length: _tripTypeTabs.length, vsync: this);
      _tripTypeTabController.addListener(() {
        if (!_tripTypeTabController.indexIsChanging && mounted) {
          setState(() {
            _selectedTripType = _tripTypeTabs[_tripTypeTabController.index];
          });
        }
      });
    } catch (e) {
      print('Error initializing TabController: $e');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTrips();
      }
    });
  }

  Future<void> _loadTrips() async {
    try {
      if (!mounted) return;
      final provider = Provider.of<DriverProvider>(context, listen: false);
      await provider.fetchTrips();
    } catch (e) {
      print('Error loading trips: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading trips: ${e.toString()}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tripTypeTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            // Header
            _buildHeader(),

            // Trip type tabs (All / Round / Normal)
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tripTypeTabController,
                indicatorColor: AppColors.lightPrimary,
                indicatorWeight: 3,
                labelColor: AppColors.lightPrimary,
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
                tabs: _tripTypeTabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
            // Trips List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Consumer<DriverProvider>(
                  builder: (context, driverProvider, child) {
                    // Show loading indicator
                    if (driverProvider.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Loading trips...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show error message if API call failed
                    if (driverProvider.errorMessage != null && driverProvider.trips.isEmpty) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Ionicons.alert_circle_outline,
                                size: 64,
                                color: Colors.red.withValues(alpha: 0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading trips',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  driverProvider.errorMessage ?? 'An error occurred',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _loadTrips(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Get trips and apply status filter first
                    final trips = driverProvider.trips;
                    var filteredTrips = _selectedFilter == 'All'
                        ? trips
                        : trips
                              .where((trip) =>
                                  (trip.status ?? '').toLowerCase() ==
                                  _selectedFilter.toLowerCase())
                              .toList();
                    // then apply trip type filter
                    if (_selectedTripType != 'All') {
                      filteredTrips = filteredTrips.where((trip) {
                        final tt = (trip.tripType ?? '').isEmpty ? 'Normal' : (trip.tripType ?? '');
                        return tt.toLowerCase() == _selectedTripType.toLowerCase();
                      }).toList();
                    }

                    // Show empty state if no trips
                    if (trips.isEmpty) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Ionicons.document_text_outline,
                                size: 64,
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No trips yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your completed trips will appear here',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _loadTrips(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Refresh',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Show filtered empty state
                    if (filteredTrips.isEmpty && _selectedFilter != 'All') {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Ionicons.document_text_outline,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No $_selectedFilter trips',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No trips matching this filter',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() => _selectedFilter = 'All');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Clear Filter',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show trips list
                    return RefreshIndicator(
                      onRefresh: () => _loadTrips(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                        itemCount: filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = filteredTrips[index];
                          return _buildTripCard(trip);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          height: 60,
          child: Center(child: FloatingBottomNav(currentIndex: 2)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 10,
        20,
        25,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                ),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/New/Group 9757.png',
                        height: 30,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/New/Group 9756.png',
                        height: 25,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _showFilterDialog,
                    icon: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'All Trips',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'View and manage your trip history',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    try {
      Color statusColor;
      IconData statusIcon;

      final status = (trip.status ?? '').toLowerCase();
      switch (status) {
        case 'completed':
          statusColor = Colors.green;
          statusIcon = Ionicons.checkmark_circle_outline;
          break;
        case 'cancelled':
          statusColor = Colors.red;
          statusIcon = Ionicons.close_circle_outline;
          break;
        case 'planned':
          statusColor = Colors.orange;
          statusIcon = Ionicons.time_outline;
          break;
        default:
          statusColor = Colors.orange;
          statusIcon = Ionicons.time_outline;
      }

      final driverName = trip.driver?.name ?? 'Unknown Driver';
      final vehicleModel = trip.vehicle?.model ?? 'Vehicle';
      final vehiclePlate = trip.vehicle?.numberPlate ?? 'N/A';
      final tripType = (trip.tripType ?? '').isEmpty ? 'Normal' : trip.tripType;
      final tripDateStr = (trip.tripDate ?? '').isNotEmpty 
        ? app_date_utils.AppDateUtils.formatDate(trip.tripDate)
        : 'No date';

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailsScreen(
                tripId: trip.id,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Ionicons.car_outline,
                        color: AppColors.lightPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trip #${trip.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          trip.status ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Ionicons.person_outline, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$driverName • ${trip.employeesCount ?? 0} passengers',
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Ionicons.calendar_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tripDateStr,
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Ionicons.car_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$vehicleModel - $vehiclePlate',
                            style: GoogleFonts.poppins(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Ionicons.navigate_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tripType,
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildTripActionButtons(trip),
            ],
          ),
        ),
      );
    } catch (e) {
      print('⚠️ Error building trip card: $e');
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Ionicons.alert_circle_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Trip #${trip.id} - Data unavailable',
                style: GoogleFonts.poppins(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTripActionButtons(Trip trip) {
    try {
      final status = (trip.status ?? '').toLowerCase();

      if (status == 'planned' || status == 'confirmed') {
      // Show Cancel on left, Call, Map, and Start Now on right for planned trips
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () => _cancelTrip(trip.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _callDriver(trip),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Ionicons.call_outline, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _openMap(trip),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Ionicons.map_outline, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _startTrip(trip.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'Start Now',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (status == 'running' ||
        status == 'in_progress' ||
        status == 'started') {
      // While trip is running we want to always show Call and Map so
      // driver can return to navigation or call passenger. Also show End button.
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Optionally keep a placeholder or left-aligned widget in future
          const SizedBox.shrink(),
          Row(
            children: [
              IconButton(
                onPressed: () => _callDriver(trip),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Ionicons.call_outline, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _openMap(trip),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Ionicons.map_outline, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _completeTrip(trip.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'End',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (status == 'completed') {
      // Completed trip cards need to hide invoice button when the underlying
      // request is of type `roster_auto`. If the trip model already contains
      // the flag we can skip any API call entirely.
      if (trip.requestType.toLowerCase() == 'roster_auto') {
        return const SizedBox.shrink();
      }

      return FutureBuilder<TripDetailsResponseModel?>(
        future: Provider.of<DriverProvider>(context, listen: false)
            .getTripDetails(trip.id),
        builder: (context, snapshot) {
          bool isRosterAuto = false;
          if (snapshot.hasData) {
            final details = snapshot.data!;
            if (details.rideRequest.requestType.toLowerCase() ==
                'roster_auto') {
              isRosterAuto = true;
            }
          }

          if (isRosterAuto) {
            return const SizedBox.shrink();
          }

          // show invoice button after data loads
          return Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                final provider =
                    Provider.of<DriverProvider>(context, listen: false);

                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Downloading invoice...',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  await provider.downloadInvoice(trip.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Invoice downloaded successfully',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Download failed',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.download),
              label: Text(
                'Download Invoice',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      );
    }

    else {
      // Default buttons for other statuses
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => _callDriver(trip),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Ionicons.call_outline, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _openMap(trip),
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Ionicons.map_outline, color: Colors.green, size: 20),
          ),
        ],
      );
    }
    } catch (e) {
      print('⚠️ Error building trip action buttons: $e');
      return const SizedBox.shrink();
    }
  }

  void _cancelTrip(int tripId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Trip',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please provide a reason for cancelling this trip:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Passenger not available',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back', style: GoogleFonts.poppins()),
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
                _initiateTripCancellation(tripId, reason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _initiateTripCancellation(int tripId, String reason) async {
    if (!mounted) return;
    try {
      // First API call to send OTP
      bool success = await Provider.of<DriverProvider>(
        context,
        listen: false,
      ).updateTripStatus(tripId, 'cancelled', cancelReason: reason);

      if (mounted && success) {
        _showCancelOtpDialog(tripId, reason);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to initiate cancellation',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to initiate cancellation: ${e.toString()}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showCancelOtpDialog(int tripId, String reason) {
    final TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter OTP to Cancel Trip',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please enter the 6-digit OTP to verify and cancel the trip.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                final otp = otpController.text.trim();
                if (otp.isEmpty || otp.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please enter a valid 6-digit OTP',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _proceedToCancelTrip(tripId, reason, otp);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Verify & Cancel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCancelTrip(int tripId, String reason, String otp) async {
    if (!mounted) return;
    try {
      await Provider.of<DriverProvider>(
        context,
        listen: false,
      ).updateTripStatus(tripId, 'cancelled', otp: otp, cancelReason: reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trip cancelled successfully',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Reload trips after successful cancellation
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _loadTrips();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to cancel trip: ${e.toString()}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showOtpDialog(int tripId) {
    final TextEditingController otpController = TextEditingController();
    bool isSubmitting = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Enter OTP to Start Ride',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please enter the 6-digit OTP provided by the client to verify and start the ride.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    enabled: !isSubmitting,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.grey[300],
                        letterSpacing: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      counterText: '',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: isSubmitting ? Colors.grey : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    final otp = otpController.text.trim();
                    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter a valid 6-digit OTP',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }

                    // Set loading state
                    setState(() {
                      isSubmitting = true;
                    });

                    await _proceedToStartTrip(tripId, otp);
                    
                    // Reset loading state if dialog is still mounted
                    if (mounted) {
                      setState(() {
                        isSubmitting = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting 
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Verify & Start',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startTrip(int tripId) async {
    try {
      //  FIRST API CALL (WITHOUT OTP)
      bool success = await Provider.of<DriverProvider>(
        context,
        listen: false,
      ).updateTripStatus(tripId, 'running');

      if (success) {
        // ✅ API success → now open OTP popup
        _showOtpDialog(tripId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Trip start failed',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  
  Future<void> _proceedToStartTrip(int tripId, String otp) async {
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      
      await driverProvider.updateTripStatus(
        tripId,
        'running',
        otp: otp,
      );

      // Get trip details for tracking
      await driverProvider.getTripDetails(tripId);
      final tripDetails = driverProvider.tripDetails;
      
      // Refresh trips list
      driverProvider.fetchTrips();

      if (mounted) {
        // Close the OTP dialog
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trip started successfully',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to trip tracking screen
        if (tripDetails != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TripTrackingScreen(
                tripId: tripId,
                tripDetails: tripDetails,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Extract clean error message
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _proceedToCompleteTrip(int tripId, String otp) async {
    try {
      await Provider.of<DriverProvider>(
        context,
        listen: false,
      ).updateTripStatus(
        tripId,
        'completed',
        otp: otp,
      );

      // ✅ Correct OTP → close popup
      if (mounted) {
        Navigator.of(context).pop();
        Provider.of<DriverProvider>(context, listen: false).fetchTrips();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trip completed successfully',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // ❌ Show actual error message from API
      if (mounted) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }


  void _showCompleteOtpDialog(int tripId) {
    final TextEditingController otpController = TextEditingController();
    bool isSubmitting = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Enter OTP to Complete Trip',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please enter the 6-digit OTP provided by the client to verify and complete the trip.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    enabled: !isSubmitting,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.grey[300],
                        letterSpacing: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      counterText: '',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: isSubmitting ? Colors.grey : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    final otp = otpController.text.trim();

                    if (otp.isEmpty || otp.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter valid 6-digit OTP'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Set loading state
                    setState(() {
                      isSubmitting = true;
                    });

                    await _proceedToCompleteTrip(tripId, otp);
                    
                    // Reset loading state if dialog is still mounted
                    if (mounted) {
                      setState(() {
                        isSubmitting = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting 
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Verify & Complete',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _completeTrip(int tripId) async {
    try {
      // FIRST API CALL (WITHOUT OTP) to trigger OTP sending
      bool success = await Provider.of<DriverProvider>(
        context,
        listen: false,
      ).updateTripStatus(tripId, 'completed');

      if (success) {
        // ✅ API success → now open OTP popup for completion
        _showCompleteOtpDialog(tripId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to initiate trip completion: $e',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _callDriver(Trip trip) {
    if (!mounted) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Call feature not implemented yet',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      print('Error in _callDriver: $e');
    }
  }

  void _openMap(Trip trip) async {
    if (!mounted) return;
    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get trip details for map navigation
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      await driverProvider.getTripDetails(trip.id);
      
      if (!mounted) return;
      
      // Close loading dialog safely
      try {
        Navigator.of(context).pop();
      } catch (e) {
        print('Error closing loading dialog: $e');
      }

      final tripDetails = driverProvider.tripDetails;
      
      if (mounted && tripDetails != null) {
        // Navigate to trip tracking screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripTrackingScreen(
              tripId: trip.id,
              tripDetails: tripDetails,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to load trip details',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        try {
          Navigator.of(context).pop(); // Try to close loading dialog
        } catch (_) {}
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading map: ${e.toString()}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    if (!mounted) return;
    try {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Filter',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...['All', 'Completed', 'Planned', 'Cancelled', 'Clear'].map(
                  (filter) => ListTile(
                    leading: Icon(
                      _getFilterIcon(filter),
                      color: _getFilterColor(filter),
                    ),
                    title: Text(filter, style: GoogleFonts.poppins()),
                    onTap: () {
                      Navigator.pop(context);
                      if (mounted) {
                        setState(() {
                          if (filter == 'Clear') {
                            _selectedFilter = 'All';
                          } else {
                            _selectedFilter = filter;
                          }
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error showing filter dialog: $e');
    }
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'All':
        return Icons.all_inclusive;
      case 'Completed':
        return Icons.check_circle;
      case 'Planned':
        return Icons.schedule;
      case 'Cancelled':
        return Icons.cancel;
      case 'Clear':
        return Icons.clear;
      default:
        return Icons.filter_list;
    }
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'All':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Planned':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      case 'Clear':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }


}
