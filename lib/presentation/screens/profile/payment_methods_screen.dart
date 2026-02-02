import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // State to track selected method (Mock functionality)
  String _selectedMethodId = 'cash'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean off-white background
      // CONFIRM BUTTON FLOATING AT BOTTOM
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment Method Updated', style: GoogleFonts.poppins()),
                  backgroundColor: const Color(0xFF1C5479),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C5479), // Primary Blue
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              shadowColor: const Color(0xFF1C5479).withValues(alpha: 0.4),
            ),
            child: Text(
              'Confirm Selection',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. CUSTOM HEADER (Clean White)
          _buildHeader(context),

          // 2. PAYMENT LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionTitle('Saved Methods'),
                _buildPaymentCard(
                  id: 'card_1234',
                  icon: Ionicons.card,
                  title: 'Mastercard •••• 1234',
                  subtitle: 'Expires 12/26',
                  onTap: () => setState(() => _selectedMethodId = 'card_1234'),
                ),
                _buildPaymentCard(
                  id: 'upi_paytm',
                  icon: Ionicons.qr_code_outline,
                  title: 'Paytm UPI',
                  subtitle: 'Linked: user@paytm',
                  onTap: () => setState(() => _selectedMethodId = 'upi_paytm'),
                ),

                const SizedBox(height: 25),
                _buildSectionTitle('Add New Method'),
                
                _buildAddMethodCard(
                  icon: Ionicons.add_circle_outline,
                  title: 'Add Credit/Debit Card',
                  onTap: () => _showAddCardSheet(context),
                ),
                _buildAddMethodCard(
                  icon: Ionicons.wallet_outline,
                  title: 'Link Wallet (PhonePe/GPay)',
                  onTap: () => _showLinkWalletSheet(context), // Updated to Sheet
                ),
                _buildAddMethodCard(
                  icon: Ionicons.globe_outline,
                  title: 'Net Banking',
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text("Redirecting to Bank Gateway...", style: GoogleFonts.poppins()),
                         backgroundColor: Colors.black87,
                       )
                     );
                  },
                ),

                const SizedBox(height: 25),
                _buildSectionTitle('Other Options'),
                
                _buildPaymentCard(
                  id: 'cash',
                  icon: Ionicons.cash_outline,
                  title: 'Cash on Delivery',
                  subtitle: 'Pay directly to driver',
                  onTap: () => setState(() => _selectedMethodId = 'cash'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 10, 20, 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Payment Methods',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedMethodId == id;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1C5479) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1C5479).withValues(alpha: 0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF1C5479) : Colors.grey.shade700, size: 24),
            ),
            const SizedBox(width: 15),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            
            // Radio Indicator
            Icon(
              isSelected ? Ionicons.radio_button_on : Ionicons.radio_button_off,
              color: isSelected ? const Color(0xFF1C5479) : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMethodCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), 
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1C5479), size: 22),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // --- BOTTOM SHEETS ---

  // 1. ADD CARD SHEET
  void _showAddCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75, // Taller for card inputs
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 25),
              Text('Add New Card', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _buildTextField('Card Number', 'XXXX XXXX XXXX XXXX', Ionicons.card_outline),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildTextField('Expiry Date', 'MM/YY', Ionicons.calendar_outline)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField('CVV', '123', Ionicons.lock_closed_outline)),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField('Card Holder Name', 'John Doe', Ionicons.person_outline),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C5479),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: Text('Save Card', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 2. LINK WALLET SHEET (Updated from Dialog)
  void _showLinkWalletSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55, // Shorter for wallet
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 25),
              Text('Link Wallet', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Securely link your UPI or digital wallet for faster payments.', style: GoogleFonts.poppins(color: Colors.grey)),
              const SizedBox(height: 25),
              
              _buildTextField('UPI ID / Mobile Number', 'example@upi', Ionicons.phone_portrait_outline),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C5479),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: Text('Verify & Link', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        const SizedBox(height: 10),
        TextField(
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, size: 22, color: const Color(0xFF1C5479).withValues(alpha: 0.6)),
            filled: true,
            fillColor: Colors.grey[50], // Very light grey bg
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), 
              borderSide: const BorderSide(color: Color(0xFF1C5479), width: 1.5)
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}



