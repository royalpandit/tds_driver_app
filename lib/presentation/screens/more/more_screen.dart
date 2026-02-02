import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_logo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../about/about_us_screen.dart';
import '../contact/contact_us_screen.dart';
import '../support/help_support_screen.dart';
import '../fuel/fuel_history_screen.dart';
import '../fuel/add_fuel_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_conditions_screen.dart';
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: AppLogo(size: 35),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.user;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        child: Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Loading...',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(themeProvider.isDarkMode ? 'Enabled' : 'Disabled'),
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          ),
          _buildMenuItem(context, Icons.info_outline, 'About Us', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()))),
          _buildMenuItem(context, Icons.contact_support_outlined, 'Contact Us', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen()))),
          _buildMenuItem(context, Icons.help_outline, 'Help & Support', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
          const SizedBox(height: 16),
          _buildMenuItem(context, Icons.local_gas_station, 'Fuel History', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FuelHistoryScreen()))),
          _buildMenuItem(context, Icons.add, 'Add Fuel Entry', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFuelScreen()))),
          const SizedBox(height: 16),
          _buildMenuItem(context, Icons.privacy_tip_outlined, 'Privacy Policy', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()))),
          _buildMenuItem(context, Icons.description_outlined, 'Terms & Conditions', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen()))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Provider.of<UserProvider>(context, listen: false).clearUser();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}



