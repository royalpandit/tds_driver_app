import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import '../../core/constants/app_colors.dart';
import '../providers/driver_provider.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, driverProvider, child) {
        final driver = driverProvider.driverDetails;

        return Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lightPrimary, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/Profile.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/New/ChatGPT Image Jan 15, 2026, 12_50_24 PM.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.person, size: 50, color: Colors.grey),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Ionicons.camera, color: Colors.white, size: 16),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),

            // Basic Info
            Text(
              driver?.personalInfo.name ?? 'Driver',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              driver?.personalInfo.email ?? 'driver@example.com',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),

            // Quick Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('Trips', driverProvider.trips.length.toString()),
                // const SizedBox(width: 30),
                // _buildStatItem('Rating', '0.0'),
                const SizedBox(width: 60),
                _buildStatItem('Status', _getStatusDisplay(driver?.status ?? 'Offline')),
              ],
            ),
          ],
        );
      },
    );
  }

  String _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'pending_verification':
        return 'Pending';
      case 'verified':
        return 'Verified';
      default:
        return status;
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}


