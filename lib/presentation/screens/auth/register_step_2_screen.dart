import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import 'register_step_3_screen.dart';

class RegisterStep2Screen extends StatefulWidget {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final int gender;
  final String dob;
  final String bloodGroup;

  const RegisterStep2Screen({
    super.key,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
  });

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseNumberController = TextEditingController();
  final _aadharNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();

  File? _licenseFrontImage;
  File? _licenseBackImage;
  File? _aadharFrontImage;
  File? _aadharBackImage;

  static const Color brandBlue = Color(0xFF1E88E5);
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(Function(File) onPicked) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onPicked(File(picked.path));
    }
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _aadharNumberController.dispose();
    _panNumberController.dispose();
    _emergencyContactController.dispose();
    _emergencyContactNameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_licenseFrontImage == null || _licenseBackImage == null || _aadharFrontImage == null || _aadharBackImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload all required images.'), backgroundColor: Colors.red),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterStep3Screen(
            // Pass all data from step 1
            firstName: widget.firstName,
            middleName: widget.middleName,
            lastName: widget.lastName,
            email: widget.email,
            phone: widget.phone,
            password: widget.password,
            gender: widget.gender,
            dob: widget.dob,
            bloodGroup: widget.bloodGroup,
            // Add step 2 data
            licenseNumber: _licenseNumberController.text,
            aadharNumber: _aadharNumberController.text,
            panNumber: _panNumberController.text,
            emergencyContact: _emergencyContactController.text,
            emergencyContactName: _emergencyContactNameController.text,
            licenseFrontImage: _licenseFrontImage!,
            licenseBackImage: _licenseBackImage!,
            aadharFrontImage: _aadharFrontImage!,
            aadharBackImage: _aadharBackImage!,
          ),
        ),
      );
    }
  }

  void _previousStep() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Step 2 of 3',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// PROGRESS INDICATOR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildProgressStep(1, false),
                      _buildProgressLine(true),
                      _buildProgressStep(2, true),
                      _buildProgressLine(true),
                      _buildProgressStep(3, false),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// TITLE
                Text(
                  'Document Details',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                /// SUBTITLE
                Text(
                  'Please provide your identification documents',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 36),

                /// DRIVING LICENSE NUMBER
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Driving License Number *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _licenseNumberController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your license number',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'License number is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// AADHAR NUMBER
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Aadhaar Number *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _aadharNumberController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your 12-digit Aadhaar number',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Aadhaar number is required';
                    }
                    if (value.length != 12) {
                      return 'Aadhaar number must be 12 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// PAN NUMBER
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'PAN Number',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _panNumberController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your PAN number (optional)',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// EMERGENCY CONTACT NAME
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Emergency Contact Name *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _emergencyContactNameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter emergency contact name',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Emergency contact name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// EMERGENCY CONTACT NUMBER
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Emergency Contact Number *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _emergencyContactController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter emergency contact number',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Emergency contact number is required';
                    }
                    if (value.length < 10) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                /// IMAGE UPLOAD SECTION
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'License Front Image *',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickImage((file) => setState(() => _licenseFrontImage = file)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _licenseFrontImage != null ? Colors.green : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: _licenseFrontImage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 32),
                              const SizedBox(height: 8),
                              Text('Image Selected', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Image.file(_licenseFrontImage!, fit: BoxFit.cover),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.grey.shade500, size: 32),
                              const SizedBox(height: 8),
                              Text('Tap to select image', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'License Back Image *',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickImage((file) => setState(() => _licenseBackImage = file)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _licenseBackImage != null ? Colors.green : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: _licenseBackImage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 32),
                              const SizedBox(height: 8),
                              Text('Image Selected', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Image.file(_licenseBackImage!, fit: BoxFit.cover),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.grey.shade500, size: 32),
                              const SizedBox(height: 8),
                              Text('Tap to select image', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Aadhar Front Image *',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickImage((file) => setState(() => _aadharFrontImage = file)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _aadharFrontImage != null ? Colors.green : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: _aadharFrontImage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 32),
                              const SizedBox(height: 8),
                              Text('Image Selected', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Image.file(_aadharFrontImage!, fit: BoxFit.cover),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.grey.shade500, size: 32),
                              const SizedBox(height: 8),
                              Text('Tap to select image', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Aadhar Back Image *',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickImage((file) => setState(() => _aadharBackImage = file)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _aadharBackImage != null ? Colors.green : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: _aadharBackImage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 32),
                              const SizedBox(height: 8),
                              Text('Image Selected', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Image.file(_aadharBackImage!, fit: BoxFit.cover),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.grey.shade500, size: 32),
                              const SizedBox(height: 8),
                              Text('Tap to select image', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                /// NAVIGATION BUTTONS
                Row(
                  children: [
                    /// BACK BUTTON
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// NEXT BUTTON
                    Expanded(
                      child: Consumer<AuthProvider>(
                        builder: (_, auth, __) {
                          return SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Next',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, bool isActive) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? brandBlue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            step.toString(),
            style: GoogleFonts.poppins(
              color: isActive ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 20,
      height: 2,
      color: isActive ? brandBlue : Colors.grey.shade300,
    );
  }
}



