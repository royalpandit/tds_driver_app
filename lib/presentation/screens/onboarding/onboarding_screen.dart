import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/storage_service.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color brandBlue = Color(0xFF0D8AD1);

  final List<Map<String, String>> _pages = [
    {
      'title': 'Book a Ride Instantly',
      'description':
          'Choose your pickup location and request a ride in seconds. Nearby drivers are ready to get you moving.',
      'image': 'assets/images/34.png',
    },
    {
      'title': 'Meet Your Driver',
      'description':
          'View driver details, vehicle information, and ratings before confirming your ride with confidence.',
      'image': 'assets/images/35.png',
    },
    {
      'title': 'Track Your Journey',
      'description':
          'Follow your ride in real time on the map and reach your destination safely and stress-free.',
      'image': 'assets/images/36.png',
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finishOnboarding() async {
    // Mark that user has seen onboarding
    final storageService = StorageService();
    await storageService.setHasSeenOnboarding(true);
    
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            /// MAIN CONTENT
            Column(
              children: [
                const SizedBox(height: 24),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 300,
                              child: Image.asset(
                                page['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Text(
                              page['title']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: brandBlue,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              page['description']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                height: 1.7,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),

            /// SKIP BUTTON
            Positioned(
              top: 8,
              right: 16,
              child: _currentPage < _pages.length - 1
                  ? TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            /// BOTTOM NAVIGATION (PROFESSIONAL)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    /// PREVIOUS (SUBTLE)
                    SizedBox(
                      height: 44,
                      child: TextButton.icon(
                        onPressed: _currentPage > 0 ? _onBack : null,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: _currentPage > 0
                              ? Colors.black87
                              : Colors.black26,
                        ),
                        label: Text(
                          'Back',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: _currentPage > 0
                                ? Colors.black87
                                : Colors.black26,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// PAGE INDICATORS
                    Row(
                      children: List.generate(_pages.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                active ? brandBlue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),

                    const Spacer(),

                    /// PRIMARY CTA
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          elevation: 0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



