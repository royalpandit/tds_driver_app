import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart' as app_date_utils;
import 'package:traveldesk_driver/core/utils/string_utils.dart';
import '../../data/models/trip_model.dart';

/// A reusable card for displaying a trip.  This mirrors the design used in
/// `AllTripsScreen._buildTripCard`, and can optionally emit a tap callback.
class TripCardWidget extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;

  const TripCardWidget({Key? key, required this.trip, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (trip.status.toLowerCase()) {
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

    return GestureDetector(
      onTap: onTap,
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
            // ===== Header =====
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
                        StringUtils.toTitleCase(trip.status),
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

            // ===== Driver Info =====
            Row(
              children: [
                const Icon(Ionicons.person_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${trip.driver.name} • ${trip.employeesCount} passengers',
                    style: GoogleFonts.poppins(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===== Trip Details =====
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
                        app_date_utils.AppDateUtils.formatDate(trip.tripDate),
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
                          '${trip.vehicle.model} - ${trip.vehicle.numberPlate}',
                          style: GoogleFonts.poppins(),
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
                      Text(StringUtils.toTitleCase(trip.tripType.isEmpty ? 'Normal' : trip.tripType), style: GoogleFonts.poppins()),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // action buttons are omitted for home recent trips
          ],
        ),
      ),
    );
  }
}
