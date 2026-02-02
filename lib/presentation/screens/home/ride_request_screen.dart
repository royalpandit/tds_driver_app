import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../../widgets/floating_bottom_nav.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../data/models/trip_model.dart';
import '../../providers/driver_provider.dart';
import 'home_screen.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({Key? key}) : super(key: key);

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoadedPending = false;
  bool _hasLoadedAccepted = false;
  bool _hasLoadedRejected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load the first tab (pending) by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentTab();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _loadCurrentTab();
    }
  }

  void _loadCurrentTab() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    
    switch (_tabController.index) {
      case 0: // Pending
        if (!_hasLoadedPending) {
          driverProvider.fetchPendingRideRequests();
          _hasLoadedPending = true;
        }
        break;
      case 1: // Accepted
        if (!_hasLoadedAccepted) {
          driverProvider.fetchAcceptedRideRequests();
          _hasLoadedAccepted = true;
        }
        break;
      case 2: // Rejected
        if (!_hasLoadedRejected) {
          driverProvider.fetchRejectedRideRequests();
          _hasLoadedRejected = true;
        }
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header with Gradient
          _buildHeader(),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.lightPrimary,
              indicatorWeight: 3,
              labelColor: AppColors.lightPrimary,
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Accepted'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Consumer<DriverProvider>(
              builder: (context, driverProvider, child) {
                if (driverProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (driverProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Ionicons.alert_circle_outline, size: 64, color: Colors.red.withValues(alpha: 0.7)),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading ride requests',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          driverProvider.errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Reset loaded flags to allow retry
                            _hasLoadedPending = false;
                            _hasLoadedAccepted = false;
                            _hasLoadedRejected = false;
                            _loadCurrentTab();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: Text(
                            'Retry',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsTab(driverProvider.pendingRideRequests, 'pending'),
                    _buildRequestsTab(driverProvider.acceptedRideRequests, 'accepted'),
                    _buildRequestsTab(driverProvider.rejectedRideRequests, 'rejected'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 1))),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C5479), Color(0xFF2E8BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/New/Group 9757.png',
                    height: 30,
                    errorBuilder: (_,__,___) => const SizedBox(),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/New/Group 9756.png',
                    height: 25,
                    errorBuilder: (_,__,___) => const SizedBox(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Ride Management',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Manage your ride requests',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(List<RideRequestOffer> rideRequests, String status) {
    return RefreshIndicator(
      onRefresh: () async {
        final driverProvider = Provider.of<DriverProvider>(context, listen: false);
        switch (status) {
          case 'pending':
            await driverProvider.fetchPendingRideRequests();
            break;
          case 'accepted':
            await driverProvider.fetchAcceptedRideRequests();
            break;
          case 'rejected':
            await driverProvider.fetchRejectedRideRequests();
            break;
        }
      },
      child: rideRequests.isEmpty
          ? _buildEmptyState(status)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: rideRequests.length,
              itemBuilder: (context, index) {
                final requestOffer = rideRequests[index];
                return _buildRideRequestCard(requestOffer, status);
              },
            ),
    );
  }

  Widget _buildEmptyState(String status) {
    String title;
    String subtitle;
    IconData icon;

    switch (status) {
      case 'pending':
        title = 'No new requests';
        subtitle = 'New ride requests will appear here';
        icon = Ionicons.time_outline;
        break;
      case 'accepted':
        title = 'No accepted rides';
        subtitle = 'Accepted ride requests will appear here';
        icon = Ionicons.checkmark_circle_outline;
        break;
      case 'rejected':
        title = 'No rejected rides';
        subtitle = 'Rejected ride requests will appear here';
        icon = Ionicons.close_circle_outline;
        break;
      default:
        title = 'No requests found';
        subtitle = 'Ride requests will appear here';
        icon = Ionicons.document_text_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRideRequestCard(RideRequestOffer requestOffer, String status) {
    final request = requestOffer.rideRequest;
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
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
                  Icon(Ionicons.car_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ride #${request.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(request.status),
            ],
          ),

          const SizedBox(height: 16),

          // Passenger Info
          Row(
            children: [
              Icon(Ionicons.person_outline, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.customer?.name ?? request.corporate?.name ?? 'Unknown Passenger',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Route Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Pickup
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        request.pickupAddress,
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
                  margin: const EdgeInsets.only(left: 5),
                  width: 2,
                  height: 20,
                  color: Colors.grey.shade300,
                ),

                // Dropoff
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        request.dropAddress,
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

          const SizedBox(height: 16),

          // Ride Details
          Row(
            children: [
              Expanded(
                child: _buildRideDetail(
                  Ionicons.calendar_outline,
                  '${app_date_utils.AppDateUtils.formatDate(request.rideDate)} at ${app_date_utils.AppDateUtils.formatTime(request.rideTime)}',
                ),
              ),
              Expanded(
                child: _buildRideDetail(
                  Ionicons.navigate_outline,
                  '${request.estimatedDistance.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildRideDetail(
                  Ionicons.car_outline,
                  request.vehicleType,
                ),
              ),
              Expanded(
                child: _buildRideDetail(
                  Ionicons.cash_outline,
                  '₹${request.estimatedDistance * 15}',
                ),
              ),
            ],
          ),

          // Action Buttons for Pending Requests
          if (isPending) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptRide(requestOffer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 3,
                      shadowColor: Colors.green.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'Accept Ride',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectRide(requestOffer),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Reject',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'accepted':
        color = Colors.blue;
        text = 'Accepted';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Completed';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRideDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _acceptRide(RideRequestOffer requestOffer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Ionicons.checkmark_circle_outline, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Accept Ride Request',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to accept this ride request?',
            style: GoogleFonts.poppins(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final driverProvider =
                Provider.of<DriverProvider>(context, listen: false);

                final success = await driverProvider.acceptRideStep1(
                  requestOffer.offerId,
                );

                if (success) {
                  _showOtpDialogForAcceptance(requestOffer);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP send nahi hua')),
                  );
                }
              },

              // onPressed: () async {
              //   // Close dialog first
              //   Navigator.pop(context);
              //
              //   // Show OTP dialog for acceptance
              //   _showOtpDialogForAcceptance(requestOffer);
              // },
              child: Text(
                'Accept',
                style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _rejectRide(RideRequestOffer requestOffer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Ionicons.close_circle_outline, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reject Ride Request',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to reject this ride request?',
            style: GoogleFonts.poppins(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Close dialog first
                Navigator.pop(context);

                // Capture context safely before async operation
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                // Show loading indicator
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Rejecting ride request...',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );

                // Perform the async operation
                final driverProvider = Provider.of<DriverProvider>(context, listen: false);
                final success = await driverProvider.respondToRideRequest(requestOffer.offerId, 'reject');

                if (success) {
                  if (mounted) {
                    _tabController.animateTo(2); // Switch to Rejected tab
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ride request rejected.',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          driverProvider.errorMessage ?? 'Failed to reject ride request. Please try again.',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Reject',
                style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOtpDialogForAcceptance(RideRequestOffer requestOffer) {
    final TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Ionicons.shield_checkmark_outline, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Enter OTP to Accept Ride',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please enter the OTP sent to the customer to verify and accept this ride request.',
                style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter 6-digit OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Ionicons.key_outline),
                ),
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
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
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _proceedToAcceptRideRequest(requestOffer, otp);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Verify & Accept',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToAcceptRideRequest(RideRequestOffer requestOffer, String otp) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.green),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Accepting ride request...',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      // Accept the ride request with OTP verification
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      // final acceptSuccess = await driverProvider.respondToRideRequest(
      //   requestOffer.offerId,
      //   'accept',
      //   otp: otp,
      // );
      final acceptSuccess = await driverProvider.acceptRideWithOtp(
        requestOffer.offerId,
        otp,
      );


      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (acceptSuccess) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Ride request accepted successfully!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Refresh the data
        await driverProvider.fetchPendingRideRequests();
        await driverProvider.fetchAcceptedRideRequests();
        _hasLoadedPending = false;
        _hasLoadedAccepted = false;
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              driverProvider.errorMessage ?? 'Failed to accept ride request. Please try again.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred. Please try again.',
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


