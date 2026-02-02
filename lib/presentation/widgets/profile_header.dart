import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/New/Group 9757.png',
                height: 30,
                errorBuilder: (_,__,___) => const SizedBox(),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/New/Group 9756.png',
                height: 25,
                errorBuilder: (_,__,___) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Profile',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}



