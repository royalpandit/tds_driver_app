import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

// MOCK IMPORTS - Replace with your actual paths
import '../providers/driver_provider.dart' as driver_provider;
import '../providers/auth_provider.dart';
import '../widgets/floating_bottom_nav.dart' as floating_nav;
import '../widgets/profile_header.dart';
import '../widgets/user_info_card.dart';
import '../widgets/profile_menu_item.dart';
import 'home/expense_screen.dart';
import 'home/ride_request_screen.dart' as ride_request;
import 'home/all_trips_screen.dart';
import 'home/vehicle_inspection_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'splash/splash_screen.dart';
import 'support/help_support_screen.dart';
import 'legal/terms_conditions_screen.dart';
import 'legal/privacy_policy_screen.dart';
import 'fuel/fuel_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider.of<driver_provider.DriverProvider>(context, listen: false).fetchDriverDetails();
      } catch (e) {
        // print("Provider error: $e");
      }
    });
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins(color: Colors.grey[600])),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Clear authentication data
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                // Navigate to splash screen which will redirect to login
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SplashScreen()),
                    (route) => false,
                  );
                }
              },
              child: Text('Logout', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
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
            // Header
            ProfileHeader(),

            // Main Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                  child: Column(
                    children: [
                      // User Info Card
                      const UserInfoCard(),
                      const SizedBox(height: 30),

                      // Menu Items
                      _buildMenuItems(),
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
        child: SizedBox(height: 60, child: Center(child: floating_nav.FloatingBottomNav(currentIndex: 3))),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Ionicons.person_outline,
          title: 'Edit Profile',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
        ),
        ProfileMenuItem(
          icon: Ionicons.car_outline,
          title: 'Ride Requests',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ride_request.RideRequestScreen())),
        ),
        ProfileMenuItem(
          icon: Ionicons.list_outline,
          title: 'Trips',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTripsScreen())),
        ),
        // ProfileMenuItem(
        //   icon: Ionicons.search_outline,
        //   title: 'Vehicle Inspection',
        //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleInspectionScreen())),
        // ),
        // ProfileMenuItem(
        //   icon: Ionicons.calculator_outline,
        //   title: 'Expense Management',
        //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen())),
        // ),
        ProfileMenuItem(
          icon: Ionicons.speedometer_outline,
          title: 'Fuel History',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FuelHistoryScreen())),
        ),
        ProfileMenuItem(
          icon: Ionicons.help_circle_outline,
          title: 'Help & Support',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
        ),
        ProfileMenuItem(
          icon: Ionicons.document_text_outline,
          title: 'Terms & Conditions',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen())),
        ),
        ProfileMenuItem(
          icon: Ionicons.shield_checkmark_outline,
          title: 'Privacy Policy',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
        ),
        ProfileMenuItem(
          icon: Ionicons.log_out_outline,
          title: 'Logout',
          onTap: () => _handleLogout(context),
          isLogout: true,
        ),
      ],
    );
  }
}




