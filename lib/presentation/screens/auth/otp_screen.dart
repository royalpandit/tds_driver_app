import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String contact;
  final String userType;

  const OtpScreen({
    super.key,
    required this.contact,
    required this.userType,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _enteredCode = '';
  final int _codeLength = 6;

  static const Color brandBlue = Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    // Note: OTP should already be sent from login screen, but we can add resend logic if needed
  }

  void _onKeyPressed(String value) {
    if (_enteredCode.length < _codeLength) {
      setState(() {
        _enteredCode += value;
      });
      if (_enteredCode.length == _codeLength) {
        _verify();
      }
    }
  }

  void _onBackspace() {
    if (_enteredCode.isNotEmpty) {
      setState(() {
        _enteredCode =
            _enteredCode.substring(0, _enteredCode.length - 1);
      });
    }
  }

  Future<void> _verify() async {
    if (_enteredCode.length != _codeLength) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    bool success;
    if (widget.userType == 'driver') {
      success = await auth.verifyDriverOtp(widget.contact, _enteredCode);
    } else {
      // Fallback for other user types (though we removed corporate)
      success = await auth.verifyOtp(widget.contact, _enteredCode, widget.userType);
    }

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
      setState(() => _enteredCode = '');
    }
  }

  Future<void> _resendOtp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    bool success;
    if (widget.userType == 'driver') {
      success = await auth.sendOtp(widget.contact, 'driver', 'login');
    } else {
      success = await auth.resendOtp(widget.contact, widget.userType, 'login');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'OTP resent successfully' : auth.errorMessage ?? 'Failed',
        ),
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
                    Icons.local_taxi_rounded,
                    size: 48,
                    color: brandBlue,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// TITLE
            Text(
              'Verify OTP',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            /// SUBTITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Enter the 6-digit code sent to\n${widget.contact}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
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
                      color: isFilled
                          ? brandBlue
                          : Colors.grey.shade300,
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

            /// KEYPAD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  _buildKeypadRow(['4', '5', '6']),
                  _buildKeypadRow(['7', '8', '9']),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconKey(Icons.backspace_outlined, _onBackspace),
                      _buildKey('0'),
                      _iconKey(Icons.check_rounded, _verify,
                          filled: true),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map(_buildKey).toList(),
      ),
    );
  }

  Widget _buildKey(String value) {
    return _KeyButton(
      label: value,
      onTap: () => _onKeyPressed(value),
    );
  }

  Widget _iconKey(IconData icon, VoidCallback onTap,
      {bool filled = false}) {
    return _KeyButton(
      icon: icon,
      filled: filled,
      onTap: onTap,
    );
  }
}

/// =====================
/// KEY BUTTON
/// =====================
class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool filled;

  const _KeyButton({
    this.label,
    this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 64,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: icon != null
            ? Icon(
                icon,
                color: filled ? Colors.white : Colors.black,
                size: 24,
              )
            : Text(
                label!,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}



