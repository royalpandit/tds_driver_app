import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Notification States
  bool _bookingNotifications = true;
  bool _offerNotifications = true;
  bool _reminderNotifications = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean off-white background
      body: Column(
        children: [
          // 1. CUSTOM HEADER
          _buildHeader(context),

          // 2. SETTINGS LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 50),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionTitle('Push Notifications'),
                _buildSwitchTile(
                  title: 'Booking Updates',
                  subtitle: 'Get notified about driver & ride status',
                  value: _bookingNotifications,
                  icon: Ionicons.car_sport_outline,
                  onChanged: (val) => setState(() => _bookingNotifications = val),
                ),
                _buildSwitchTile(
                  title: 'Offers & Promotions',
                  subtitle: 'Receive exclusive deals and discounts',
                  value: _offerNotifications,
                  icon: Ionicons.pricetag_outline,
                  onChanged: (val) => setState(() => _offerNotifications = val),
                ),
                _buildSwitchTile(
                  title: 'Ride Reminders',
                  subtitle: 'Get alerts before your scheduled ride',
                  value: _reminderNotifications,
                  icon: Ionicons.alarm_outline,
                  onChanged: (val) => setState(() => _reminderNotifications = val),
                ),

                const SizedBox(height: 25),
                _buildSectionTitle('Communication'),
                
                _buildSwitchTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive invoices and updates via email',
                  value: _emailNotifications,
                  icon: Ionicons.mail_outline,
                  onChanged: (val) => setState(() => _emailNotifications = val),
                ),
                _buildSwitchTile(
                  title: 'SMS Notifications',
                  subtitle: 'Receive updates via SMS',
                  value: _smsNotifications,
                  icon: Ionicons.chatbubble_ellipses_outline,
                  onChanged: (val) => setState(() => _smsNotifications = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 10, 20, 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Notifications',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance spacing
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF1C5479).withValues(alpha: 0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? const Color(0xFF1C5479) : Colors.grey.shade600,
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          
          // Switch
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF1C5479),
              activeTrackColor: const Color(0xFF1C5479).withValues(alpha: 0.3),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}



