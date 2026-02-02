import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../../data/services/storage_service.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() {
      _isNavigating = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final storageService = StorageService();
    
    final isLoggedIn = await authProvider.isAuthenticated();
    
    if (isLoggedIn) {
      // User has stored login data, validate with API
      try {
        final success = await driverProvider.fetchDriverDetails();
        if (success && driverProvider.driverDetails != null) {
          // Valid authentication, go to home screen
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
          return;
        }
      } catch (e) {
        // API call failed, token might be expired
        print('Authentication validation failed: $e');
      }
      
      // Authentication failed or invalid, clear stored data and go to login
      await authProvider.logout();
    }
    
    // Not logged in or authentication failed, check onboarding status
    final hasSeenOnboarding = await storageService.hasSeenOnboarding();
    
    if (!mounted) return;
    
    if (hasSeenOnboarding) {
      // User has seen onboarding before, go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // First time user, show onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFC4E1F4), // Light blue
              Color(0xFFFFFFFF), // White
            ],
          ),
        ),
        child: Stack(
          children: [
            /// CENTER LOGO (TWO IMAGES STACKED)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/New/Group 9757 (2).png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.directions_car_rounded,
                        size: 50,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Image.asset(
                      'assets/New/Group 9756 (2).png',
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.business,
                        size: 45,
                        color: Colors.orange,
                      ),
                    ),
                    if (_isNavigating) ...[
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            /// BOTTOM CITYSCAPE IMAGE (UNCHANGED)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/splash.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.location_city,
                  size: 120,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



