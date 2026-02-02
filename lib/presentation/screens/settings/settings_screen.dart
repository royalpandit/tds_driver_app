import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [ 
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildSettingsCard(
                          context,
                          child: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return SwitchListTile(
                                value: themeProvider.isDarkMode,
                                onChanged: (value) => themeProvider.toggleTheme(),
                                title: const Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                subtitle: Text(
                                  themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                                  style: const TextStyle(fontFamily: 'Roboto'),
                                ),
                                secondary: Icon(
                                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard(
                          context,
                          child: SwitchListTile(
                            value: true,
                            onChanged: (val) {},
                            title: const Text(
                              'Notifications',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            subtitle: const Text(
                              'Receive booking updates',
                              style: TextStyle(fontFamily: 'Roboto'),
                            ),
                            secondary: const Icon(Icons.notifications, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard(
                          context,
                          child: SwitchListTile(
                            value: true,
                            onChanged: (val) {},
                            title: const Text(
                              'Location Services',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            subtitle: const Text(
                              'Allow location access',
                              style: TextStyle(fontFamily: 'Roboto'),
                            ),
                            secondary: const Icon(Icons.location_on, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard(
                          context,
                          child: const ListTile(
                            leading: Icon(Icons.language, color: Colors.black),
                            title: Text(
                              'Language',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            subtitle: Text(
                              'English',
                              style: TextStyle(fontFamily: 'Roboto'),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard(
                          context,
                          child: const ListTile(
                            leading: Icon(Icons.info_outline, color: Colors.black),
                            title: Text(
                              'App Version',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            subtitle: Text(
                              '1.0.0',
                              style: TextStyle(fontFamily: 'Roboto'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 180),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}



