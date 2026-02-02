import 'package:flutter/material.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/floating_bottom_nav.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: AppLogo(size: 35),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing and using Traveldesk Solutions services, you accept and agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services.',
            ),
            _buildSection(
              context,
              '2. Booking and Reservations',
              '• All bookings are subject to availability\n• You must provide accurate information\n• Booking confirmation will be sent via SMS/email\n• Advance bookings can be made up to 7 days ahead\n• Changes to bookings must be made at least 1 hour before pickup',
            ),
            _buildSection(
              context,
              '3. Cancellation Policy',
              '• Free cancellation up to 1 hour before pickup\n• Cancellations within 1 hour: 50% charge\n• No-shows: Full booking amount charged\n• Refunds processed within 5-7 business days\n• Emergency cancellations considered case-by-case',
            ),
            _buildSection(
              context,
              '4. Payment Terms',
              '• All fares displayed are inclusive of applicable taxes\n• Payment can be made via cash, card, UPI, or wallet\n• Additional charges may apply for tolls and parking\n• Waiting charges: ₹2/minute after 5 minutes grace period\n• Surge pricing may apply during peak hours',
            ),
            _buildSection(
              context,
              '5. User Responsibilities',
              'As a user, you agree to:\n\n• Provide accurate pickup and drop locations\n• Be ready at pickup time\n• Treat drivers with respect\n• Not damage vehicle property\n• Not engage in illegal activities\n• Not carry prohibited items',
            ),
            _buildSection(
              context,
              '6. Driver Conduct',
              'Our drivers are expected to:\n\n• Arrive on time for pickups\n• Maintain clean vehicles\n• Follow traffic rules and regulations\n• Be courteous and professional\n• Not demand extra payment\n• Ensure passenger safety',
            ),
            _buildSection(
              context,
              '7. Liability',
              'Traveldesk Solutions:\n\n• Is not liable for personal belongings left in vehicles\n• Maintains insurance coverage for all rides\n• Is not responsible for delays due to traffic or weather\n• Reserves the right to refuse service\n• May suspend accounts for policy violations',
            ),
            _buildSection(
              context,
              '8. Modifications',
              'We reserve the right to modify these terms at any time. Continued use of our services after changes constitutes acceptance of the updated terms. Users will be notified of significant changes.',
            ),
            _buildSection(
              context,
              '9. Contact Information',
              'For questions about these terms:\n\nEmail: legal@traveldesksolutions.in\nPhone: +91 1800-123-4567\nAddress: Mumbai, Maharashtra, India\n\nEffective Date: December 2025',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 5))),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms & Conditions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please read these terms carefully',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



