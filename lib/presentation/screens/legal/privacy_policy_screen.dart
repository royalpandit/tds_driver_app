import 'package:flutter/material.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/floating_bottom_nav.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
              '1. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n• Personal information (name, email, phone number)\n• Booking details (pickup/drop locations, dates, times)\n• Payment information (processed securely)\n• Location data when using our services\n• Device information and app usage data',
            ),
            _buildSection(
              context,
              '2. How We Use Your Information',
              'We use collected information to:\n\n• Process and manage your bookings\n• Provide customer support\n• Send booking confirmations and updates\n• Improve our services and user experience\n• Prevent fraud and ensure security\n• Comply with legal obligations',
            ),
            _buildSection(
              context,
              '3. Information Sharing',
              'We may share your information with:\n\n• Drivers assigned to your bookings\n• Payment processors for transactions\n• Service providers who assist our operations\n• Law enforcement when required by law\n\nWe never sell your personal information to third parties.',
            ),
            _buildSection(
              context,
              '4. Data Security',
              'We implement industry-standard security measures to protect your data:\n\n• Encrypted data transmission (SSL/TLS)\n• Secure payment processing\n• Regular security audits\n• Access controls and authentication\n• Data backup and recovery systems',
            ),
            _buildSection(
              context,
              '5. Your Rights',
              'You have the right to:\n\n• Access your personal data\n• Request correction of inaccurate data\n• Request deletion of your data\n• Opt-out of marketing communications\n• Withdraw consent at any time',
            ),
            _buildSection(
              context,
              '6. Data Retention',
              'We retain your information for as long as necessary to provide our services and comply with legal obligations. Booking history is retained for 3 years, after which it may be anonymized or deleted.',
            ),
            _buildSection(
              context,
              '7. Contact Us',
              'For privacy-related questions or concerns, contact us at:\n\nEmail: privacy@traveldesksolutions.in\nPhone: +91 1800-123-4567\n\nLast Updated: December 2025',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(height: 60, child: Center(child: FloatingBottomNav(currentIndex: 6))),
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
            Icons.security,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Privacy Matters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We are committed to protecting your personal information',
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



