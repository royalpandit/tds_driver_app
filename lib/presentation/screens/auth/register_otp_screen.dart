import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

import 'dart:io';

class RegisterOtpScreen extends StatefulWidget {
  final String email;
  final String firstName;
  final String middleName;
  final String lastName;
  final String phone;
  final String password;
  final int gender;
  final String dob;
  final String bloodGroup;
  final String licenseNumber;
  final String aadharNumber;
  final String panNumber;
  final String emergencyContact;
  final String emergencyContactName;
  final String vehicleNumber;
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleYear;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String address;
  final String state;
  final String city;
  final String pincode;
  final File licenseFrontImage;
  final File licenseBackImage;
  final File aadharFrontImage;
  final File aadharBackImage;

  const RegisterOtpScreen({
    super.key,
    required this.email,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phone,
    required this.password,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.licenseNumber,
    required this.aadharNumber,
    required this.panNumber,
    required this.emergencyContact,
    required this.emergencyContactName,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleYear,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.address,
    required this.state,
    required this.city,
    required this.pincode,
    required this.licenseFrontImage,
    required this.licenseBackImage,
    required this.aadharFrontImage,
    required this.aadharBackImage,
  });

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  static const int _codeLength = 6;
  String _enteredCode = '';

  static const Color brandBlue = Color(0xFF0D8AD1);

  @override
  void initState() {
    super.initState();
    // Automatically send OTP when screen loads - use post frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialOtp();
    });
  }

  Future<void> _sendInitialOtp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.sendDriverOtp(widget.email, 'register',
      firstName: widget.firstName,
      lastName: widget.lastName,
      gender: widget.gender,
      phone: widget.phone,
      password: widget.password,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your email successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: ${auth.errorMessage ?? 'Unknown error'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onKeyTap(String value) {
    if (_enteredCode.length < _codeLength) {
      setState(() {
        _enteredCode += value;
      });

      if (_enteredCode.length == _codeLength) {
        _verifyAndRegister();
      }
    }
  }

  void _onBackspace() {
    if (_enteredCode.isNotEmpty) {
      setState(() {
        _enteredCode = _enteredCode.substring(0, _enteredCode.length - 1);
      });
    }
  }

  Future<void> _verifyAndRegister() async {
    if (_enteredCode.length != _codeLength) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // First verify OTP with registration data
    final verifySuccess = await auth.verifyOtp(widget.email, _enteredCode, 'driver', 
      expectToken: true, // For register, expect token
      firstName: widget.firstName,
      lastName: widget.lastName,
      gender: widget.gender,
    );

    if (!verifySuccess) {
      if (mounted && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _enteredCode = '');
      }
      return;
    }

    // OTP verified and registration completed, navigate to home
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Driver registration successful! Welcome to TravelDesk Driver App'),
            backgroundColor: Colors.green[50],
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate to home screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _resendOtp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.sendDriverOtp(widget.email, 'register',
      firstName: widget.firstName,
      lastName: widget.lastName,
      gender: widget.gender,
      phone: widget.phone,
      password: widget.password,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'OTP resent successfully' : auth.errorMessage ?? 'Failed to resend OTP',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// LOGO / ILLUSTRATION
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 245, 245, 245),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/Group 4.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.verified_user,
                    size: 80,
                    color: brandBlue,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// TITLE
            Text(
              'Verify Your Email',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            /// SUBTITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Enter the 6-digit code sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 36),

            /// OTP BOXES
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_codeLength, (index) {
                final isFilled = index < _enteredCode.length;
                return Container(
                  width: 48,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFilled ? brandBlue : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    isFilled ? _enteredCode[index] : '',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            /// RESEND
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                return TextButton(
                  onPressed: auth.isLoading ? null : _resendOtp,
                  child: Text(
                    'Resend OTP',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: brandBlue,
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            /// CUSTOM NUMERIC KEYPAD
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                return _CustomKeypad(
                  onKeyTap: auth.isLoading ? (_) {} : _onKeyTap,
                  onBackspace: auth.isLoading ? () {} : _onBackspace,
                  isLoading: auth.isLoading,
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CustomKeypad extends StatelessWidget {
  final Function(String) onKeyTap;
  final VoidCallback onBackspace;
  final bool isLoading;

  const _CustomKeypad({
    required this.onKeyTap,
    required this.onBackspace,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 12),
          _buildRow(['', '0', 'back']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 80, height: 60);
        }
        if (key == 'back') {
          return _KeyButton(
            onTap: isLoading ? () {} : onBackspace,
            child: Icon(
              Icons.backspace_outlined,
              color: isLoading ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          );
        }
        return _KeyButton(
          onTap: isLoading ? () {} : () => onKeyTap(key),
          child: Text(
            key,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: isLoading ? Colors.grey.shade400 : Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _KeyButton({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}



