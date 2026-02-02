import 'package:flutter/material.dart';
import '../../widgets/app_logo.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: AppLogo(size: 35),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(context),
            _buildStorySection(context),
            _buildStatsSection(context),
            _buildValuesSection(context),
            _buildMissionSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          const AppLogo(size: 80),
          const SizedBox(height: 16),
          Text(
            'Traveldesk Solutions',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Journey, Our Priority',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Story',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Founded with a vision to revolutionize transportation in India, Traveldesk Solutions has been connecting people with reliable, safe, and affordable cab services since our inception.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 12),
          Text(
            'We believe that travel should be stress-free and accessible to everyone. With our extensive network across 50+ cities and a fleet of well-maintained vehicles, we\'re committed to making every journey comfortable and memorable.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(context, '10K+', 'Happy Customers'),
          Container(width: 1, height: 60, color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
          _buildStatCard(context, '50+', 'Cities'),
          Container(width: 1, height: 60, color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
          _buildStatCard(context, '100K+', 'Trips'),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildValuesSection(BuildContext context) {
    final values = [
      {
        'icon': Icons.verified_user,
        'title': 'Safety First',
        'desc': 'All drivers are verified and vehicles regularly inspected',
      },
      {
        'icon': Icons.schedule,
        'title': '24/7 Service',
        'desc': 'Available round the clock for your convenience',
      },
      {
        'icon': Icons.price_check,
        'title': 'Transparent Pricing',
        'desc': 'No hidden charges, fair and upfront pricing',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Customer Support',
        'desc': 'Dedicated team to assist you anytime',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Values',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...values.map((value) => _buildValueCard(context, value)),
        ],
      ),
    );
  }

  Widget _buildValueCard(BuildContext context, Map<String, dynamic> value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                value['icon'] as IconData,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value['desc'] as String,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Mission',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'To provide safe, reliable, and affordable transportation solutions that enhance the travel experience for millions of Indians across the country.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Fleet Manager',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'A Vehicle Management System\nProudly serving you',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(context, '5+', 'Cities serviced'),
                _buildStatCard(context, '10+', 'Vehicles serving'),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Minds Behind Fleet Manager',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTeamMember(context, 'Elliot Hirthe', 'Owner'),
            _buildTeamMember(context, 'Kathlyn Wisoky IV', 'Owner'),
            _buildTeamMember(context, 'Prof. Juliana Mante', 'Owner'),
            _buildTeamMember(context, 'Deron Ortiz', 'Owner'),
            _buildTeamMember(context, 'Dr. Jailyn Feil', 'Owner'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildTeamMember(BuildContext context, String name, String role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role, style: TextStyle(color: Theme.of(context).primaryColor)),
            const SizedBox(height: 4),
            const Text(
              'Lorem ipsum dolor, sit amet consectetur adipisicing elit. Temporibus neque est nemo et ipsum fugiat.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }



