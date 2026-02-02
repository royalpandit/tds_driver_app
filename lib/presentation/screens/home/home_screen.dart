import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

// MOCK IMPORTS - Replace with your actual paths
import '../../widgets/floating_bottom_nav.dart' as floating_nav;
import '../../../core/constants/app_colors.dart' as app_colors;
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../data/models/trip_model.dart';
import 'all_trips_screen.dart' as all_trips;
import 'ride_request_screen.dart' as ride_request;
import '../../providers/driver_provider.dart' as driver_provider;
// import '../../../data/models/trip_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Toggle for Driver Online/Offline status
  bool isOnline = true; 

  @override
  void initState() {
    super.initState();
    // Fetch dashboard stats when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<driver_provider.DriverProvider>().fetchDashboardStats();
      context.read<driver_provider.DriverProvider>().fetchTrips();
      context.read<driver_provider.DriverProvider>().fetchPendingRideRequests();
    });
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/New/Group 9757.png', height: 40, errorBuilder: (_, _, _) => const Icon(Icons.drive_eta, size: 40)),
              const SizedBox(width: 10),
              Image.asset('assets/New/Group 9756.png', height: 30, errorBuilder: (_, _, _) => const SizedBox()),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Welcome back, Driver!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Ready for your next ride?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
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
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Summary Cards (Rides, Earnings, Hours) ---
                      _buildSummaryCards(),
                      
                      const SizedBox(height: 25),

                      // --- Pending Requests ---
                      _buildSectionTitle("Pending Requests"),
                      const SizedBox(height: 15),
                      _buildPendingRequests(),
                      
                      const SizedBox(height: 25),

                      // --- Fuel History ---
                      _buildSectionTitle('Fuel History'),
                      const SizedBox(height: 10),
                      _buildFuelHistorySection(),
                      
                      const SizedBox(height: 25),

                      // --- Ongoing Trip (only show if there are running trips) ---
                      Consumer<driver_provider.DriverProvider>(
                        builder: (context, provider, child) {
                          final runningTrips = provider.trips.where((trip) => 
                            trip.status.toLowerCase() == 'running' || 
                            trip.status.toLowerCase() == 'in_progress' || 
                            trip.status.toLowerCase() == 'started'
                          ).toList();
                          
                          if (runningTrips.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Ongoing Trip"),
                                const SizedBox(height: 15),
                                _buildOngoingTrip(runningTrips.first),
                                const SizedBox(height: 25),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // --- Recent Trips ---
                      _buildSectionTitle("Recent Trips"),
                      const SizedBox(height: 15),
                      _buildRecentTrips(),
                      
                      const SizedBox(height: 30),

                      // --- All Trips Button ---
                      _buildAllTripsButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(height: 60, child: Center(child: floating_nav.FloatingBottomNav(currentIndex: 0))),
      ),
    );
  }



  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<driver_provider.DriverProvider>(
      builder: (context, provider, child) {
        final stats = provider.dashboardStats;
        final isLoading = provider.isLoading;
        
        if (isLoading) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildLoadingCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLoadingCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLoadingCard()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildLoadingCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLoadingCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLoadingCard()),
                ],
              ),
              const SizedBox(height: 20),
              _buildLoadingCard(),
              const SizedBox(height: 20),
              _buildLoadingCard(),
            ],
          );
        }
        
        final tripStats = stats['trip_stats'] ?? {};
        final todayActivity = stats['today_activity'] ?? {};
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Trip Statistics'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('Total Trips', (tripStats['total_trips'] ?? 0).toString(), Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Upcoming', (tripStats['upcoming_trips'] ?? 0).toString(), Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Planned', (tripStats['planned_trips'] ?? 0).toString(), Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('Running', (tripStats['running_trips'] ?? 0).toString(), Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Completed', (tripStats['completed_trips'] ?? 0).toString(), Colors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Pending Offers', (tripStats['pending_offers'] ?? 0).toString(), Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Today\'s Activity'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('Completed', (todayActivity['today_completed'] ?? 0).toString(), Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Planned', (todayActivity['today_planned'] ?? 0).toString(), Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('In Progress', (todayActivity['today_progress'] ?? 0).toString(), Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Fuel History'),
            const SizedBox(height: 10),
            _buildFuelHistorySection(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20, // Slightly smaller to prevent overflow
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(height: 8),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRideRequestCard(RideRequestOffer request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with passenger and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Ionicons.person_outline, color: app_colors.AppColors.lightPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    request.rideRequest.customer?.name ?? 'Unknown Passenger',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Route Information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Pickup
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.rideRequest.pickupAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                // Connecting line
                Container(
                  margin: const EdgeInsets.only(left: 3),
                  width: 1,
                  height: 12,
                  color: Colors.grey.shade300,
                ),

                // Dropoff
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.rideRequest.dropAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Date and Time
          Row(
            children: [
              Icon(Ionicons.calendar_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${app_date_utils.AppDateUtils.formatDate(request.rideRequest.rideDate)} at ${app_date_utils.AppDateUtils.formatTime(request.rideRequest.rideTime)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _respondToRideRequest(request.offerId, 'reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Reject',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _respondToRideRequest(request.offerId, 'accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Accept',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _respondToRideRequest(int offerId, String action) async {
    final provider = context.read<driver_provider.DriverProvider>();
    final success = await provider.respondToRideRequest(offerId, action);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ride request ${action}ed successfully',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: action == 'accept' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${action} ride request',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _startTrip(int tripId) async {
    try {
      await Provider.of<driver_provider.DriverProvider>(context, listen: false).updateTripStatus(tripId, 'running');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trip started successfully',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to start trip: $e',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }



  void _callDriver(Trip trip) {
    // Implement phone call functionality
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
  }

  void _openMap(Trip trip) {
    // Implement map functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening map for Trip #${trip.id}',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildFuelHistorySection() {
    return Consumer<driver_provider.DriverProvider>(
      builder: (context, provider, child) {
        final fuelHistory = provider.dashboardStats['fuel_history'] as List<dynamic>? ?? [];
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: fuelHistory.isEmpty
              ? Center(
                  child: Text(
                    'No fuel history available',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : Column(
                  children: fuelHistory.map<Widget>((fuel) {
                    // Use the cost field directly from API
                    final cost = double.tryParse(fuel['cost']?.toString() ?? '0') ?? 0.0;
                    
                    return ListTile(
                      title: Text('Fuel Entry', style: GoogleFonts.poppins(fontSize: 14)),
                      subtitle: Text('Date: ${fuel['date'] ?? 'N/A'}', style: GoogleFonts.poppins(fontSize: 12)),
                      trailing: Text('₹${cost.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildPendingRequests() {
    return Consumer<driver_provider.DriverProvider>(
      builder: (context, provider, child) {
        final pendingRequests = provider.pendingRideRequests;
        final isLoading = provider.isLoading;
        
        if (isLoading) {
          return _buildLoadingCard();
        }
        
        if (pendingRequests.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'No pending ride requests',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }
        return SizedBox(
          height: 270, // card height ke hisaab se adjust kar sakte ho
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pendingRequests.length > 5 ? 5 : pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              return Container(
                width: 370, // ek card ki width
                margin: const EdgeInsets.only(right: 12),
                child: _buildRideRequestCard(request),
              );
            },
          ),
        );

        // return Column(
        //   children: [
        //     ...pendingRequests.take(2).map((request) => _buildRideRequestCard(request)).toList(),
        //     if (pendingRequests.length > 2)
        //       Container(
        //         margin: const EdgeInsets.only(top: 12),
        //         width: double.infinity,
        //         child: ElevatedButton(
        //           onPressed: () {
        //             // Navigate to ride request screen
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                 builder: (_) => const ride_request.RideRequestScreen(),
        //               ),
        //             );
        //           },
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: app_colors.AppColors.lightPrimary,
        //             foregroundColor: Colors.white,
        //             padding: const EdgeInsets.symmetric(vertical: 12),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(12),
        //             ),
        //           ),
        //           child: Text(
        //             'Show More',
        //             style: GoogleFonts.poppins(
        //               fontSize: 14,
        //               fontWeight: FontWeight.w600,
        //             ),
        //           ),
        //         ),
        //       ),
        //   ],
        // );
      },
    );
  }

  Widget _buildOngoingTrip(Trip trip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Ionicons.car_outline, color: app_colors.AppColors.lightPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Trip #${trip.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Running',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Driver and Employee Info
          Row(
            children: [
              Icon(Ionicons.person_outline, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${trip.driver.name} • ${trip.employeesCount} passengers',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Route
          Row(
            children: [
              Icon(Ionicons.location_outline, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${trip.routes.morning?.name ?? 'N/A'} → ${trip.routes.evening?.name ?? 'N/A'}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // End Trip Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _completeTrip(trip.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'End Trip',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTrips() {
    return Consumer<driver_provider.DriverProvider>(
      builder: (context, provider, child) {
        final trips = provider.trips;
        final isLoading = provider.isLoading;
        
        if (isLoading) {
          return _buildLoadingCard();
        }
        
        // Filter for completed trips
        final completedTrips = trips.where((trip) => 
          trip.status.toLowerCase() == 'completed'
        ).toList();
        
        if (completedTrips.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'No recent trips',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }
        
        return Column(
          children: completedTrips.take(3).map((trip) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip #${trip.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${trip.routes.morning?.name ?? 'N/A'} → ${trip.routes.evening?.name ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹0', // TODO: Add fare field to Trip model or get from API
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Completed',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )).toList(),
        );
      },
    );
  }

  void _completeTrip(int tripId) async {
    try {
      await Provider.of<driver_provider.DriverProvider>(context, listen: false).updateTripStatus(tripId, 'completed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Trip completed successfully',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to complete trip: $e',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
  //   required dynamic trip,
  //   required String status,
  //   required Color statusColor,
  //   required bool showAcceptReject,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Trip #${trip.id}',
  //               style: GoogleFonts.poppins(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: statusColor.withValues(alpha: 0.1),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Text(
  //                 status,
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w500,
  //                   color: statusColor,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             Icon(Icons.calendar_today, size: 16, color: Colors.grey),
  //             const SizedBox(width: 8),
  //             Text(
  //               'Date: ${trip.tripDate}',
  //               style: GoogleFonts.poppins(
  //                 fontSize: 14,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Icon(Icons.location_on, size: 16, color: Colors.red),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 'Route: ${trip.routes?.morning?.name ?? trip.routes?.evening?.name ?? 'Not specified'}',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 14,
  //                   color: Colors.black87,
  //                 ),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Icon(Icons.flag, size: 16, color: Colors.green),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 'Type: ${trip.tripType ?? 'Not specified'}',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 14,
  //                   color: Colors.black87,
  //                 ),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Icon(Icons.directions_car, size: 16, color: Colors.blue),
  //             const SizedBox(width: 8),
  //             Text(
  //               'Vehicle: ${trip.vehicle?.model ?? 'Not assigned'}',
  //               style: GoogleFonts.poppins(
  //                 fontSize: 14,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Icon(Icons.people, size: 16, color: Colors.purple),
  //             const SizedBox(width: 8),
  //             Text(
  //               'Employees: ${trip.employeesCount ?? 0}',
  //               style: GoogleFonts.poppins(
  //                 fontSize: 14,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //           ],
  //         ),
  //         if (showAcceptReject) ...[
  //           const SizedBox(height: 16),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     // TODO: Implement accept trip
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(content: Text('Trip accepted')),
  //                     );
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.green,
  //                     foregroundColor: Colors.white,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'Accept',
  //                     style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: OutlinedButton(
  //                   onPressed: () {
  //                     // TODO: Implement reject trip
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(content: Text('Trip rejected')),
  //                     );
  //                   },
  //                   style: OutlinedButton.styleFrom(
  //                     side: const BorderSide(color: Colors.red),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'Reject',
  //                     style: GoogleFonts.poppins(
  //                       color: Colors.red,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAllTripsButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const all_trips.AllTripsScreen())),
        style: ElevatedButton.styleFrom(
          backgroundColor: app_colors.AppColors.lightPrimary,
          elevation: 2,
          shadowColor: app_colors.AppColors.lightPrimary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          "View All Trips",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  // Widget _buildRideCard({
  //   required String passengerName,
  //   required String pickupLocation,
  //   required String dropLocation,
  //   required String time,
  //   required String status,
  //   required Color statusColor,
  //   required bool isOngoing,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               passengerName,
  //               style: GoogleFonts.poppins(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: statusColor.withValues(alpha: 0.1),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Text(
  //                 status,
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w500,
  //                   color: statusColor,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             Icon(Icons.location_on, size: 16, color: Colors.red),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 pickupLocation,
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 14,
  //                   color: Colors.black87,
  //                 ),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Icon(Icons.flag, size: 16, color: Colors.green),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 dropLocation,
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 14,
  //                   color: Colors.black87,
  //                 ),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               children: [
  //                 Icon(Icons.access_time, size: 16, color: Colors.grey),
  //                 const SizedBox(width: 4),
  //                 Text(
  //                   time,
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 12,
  //                     color: Colors.grey[600],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             if (isOngoing)
  //               ElevatedButton(
  //                 onPressed: () {
  //                   // Navigate to ride details or tracking
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: app_colors.AppColors.lightPrimary,
  //                   foregroundColor: Colors.white,
  //                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   'Track',
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
}



