import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../core/constants/app_colors.dart' as app_colors;
import '../screens/home/home_screen.dart' as home;
import '../screens/home/all_trips_screen.dart' as trips;
import '../screens/home/ride_request_screen.dart' as ride;
import '../screens/profile_screen.dart' as profile;

const Color primaryBlue = app_colors.AppColors.lightPrimary;
const Color accentYellow = app_colors.AppColors.lightAccent;
const Color inactiveGrey = app_colors.AppColors.lightTextBody;

class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTabTapped;
  const FloatingBottomNav({super.key, this.currentIndex = 0, this.onTabTapped});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (onTabTapped != null) {
      onTabTapped!(index);
    } else {
      // Fallback for when used independently
      Widget? screen;
      switch (index) {
        case 0:
          screen = const home.HomeScreen();
          break;
        case 1:
          screen = const ride.RideRequestScreen();
          break;
        case 2:
          screen = const trips.AllTripsScreen();
          break;
        case 3:
          screen = const profile.ProfileScreen();
          break;
      }

      if (screen != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => screen!),
          (route) => false,
        );
      }
    }
  }

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool selected = index == currentIndex;

    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : inactiveGrey,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(
              context: context,
              icon: Ionicons.home_outline,
              label: 'Home',
              index: 0,
            ),
            _navItem(
              context: context,
              icon: Ionicons.notifications_outline,
              label: 'Requests',
              index: 1,
            ),
            _navItem(
              context: context,
              icon: Ionicons.car_outline,
              label: 'Trips',
              index: 2,
            ),
            _navItem(
              context: context,
              icon: Ionicons.person_outline,
              label: 'Profile',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }
}



