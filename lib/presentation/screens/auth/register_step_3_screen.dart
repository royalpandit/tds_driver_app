import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_otp_screen.dart';

import 'dart:io';

class RegisterStep3Screen extends StatefulWidget {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
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
  final File licenseFrontImage;
  final File licenseBackImage;
  final File aadharFrontImage;
  final File aadharBackImage;

  const RegisterStep3Screen({
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
    required this.licenseNumber,
    required this.aadharNumber,
    required this.panNumber,
    required this.emergencyContact,
    required this.emergencyContactName,
    required this.licenseFrontImage,
    required this.licenseBackImage,
    required this.aadharFrontImage,
    required this.aadharBackImage,
  });

  @override
  State<RegisterStep3Screen> createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends State<RegisterStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  int _selectedYear = DateTime.now().year;

  static const Color brandBlue = Color(0xFF1E88E5);

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    _vehicleYearController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _submit() async {
    // Validate current form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that all required data from previous steps is present
    if (widget.firstName.isEmpty ||
        widget.lastName.isEmpty ||
        widget.email.isEmpty ||
        widget.phone.isEmpty ||
        widget.password.isEmpty ||
        widget.licenseNumber.isEmpty ||
        widget.aadharNumber.isEmpty ||
        widget.gender <= 0 ||
        widget.gender > 2 ||
        _addressController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _pincodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to OTP screen with all collected data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterOtpScreen(
          firstName: widget.firstName,
          middleName: widget.middleName,
          lastName: widget.lastName,
          email: widget.email,
          phone: widget.phone,
          password: widget.password,
          gender: widget.gender,
          dob: widget.dob,
          bloodGroup: widget.bloodGroup,
          licenseNumber: widget.licenseNumber,
          aadharNumber: widget.aadharNumber,
          panNumber: widget.panNumber,
          emergencyContact: widget.emergencyContact,
          emergencyContactName: widget.emergencyContactName,
          vehicleNumber: _vehicleNumberController.text,
          vehicleModel: _vehicleModelController.text,
          vehicleColor: _vehicleColorController.text,
          vehicleYear: _vehicleYearController.text,
          bankName: _bankNameController.text,
          accountNumber: _accountNumberController.text,
          ifscCode: _ifscCodeController.text,
          address: _addressController.text,
          state: _stateController.text,
          city: _cityController.text,
          pincode: _pincodeController.text,
          licenseFrontImage: widget.licenseFrontImage,
          licenseBackImage: widget.licenseBackImage,
          aadharFrontImage: widget.aadharFrontImage,
          aadharBackImage: widget.aadharBackImage,
        ),
      ),
    );
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
          'Step 3 of 3',
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
                const SizedBox(height: 20),

                /// PROGRESS INDICATOR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildProgressStep(1, false),
                      _buildProgressLine(true),
                      _buildProgressStep(2, false),
                      _buildProgressLine(true),
                      _buildProgressStep(3, true),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// TITLE
                Text(
                  'Vehicle & Banking Details',
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
                  'Please provide your vehicle and banking information',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 36),

                /// VEHICLE NUMBER
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vehicle Number *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _vehicleNumberController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'e.g., MH12AB1234',
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
                      return 'Vehicle number is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// VEHICLE MODEL
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vehicle Model *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _vehicleModelController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'e.g., Honda City, Tata Indigo',
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
                      return 'Vehicle model is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// VEHICLE COLOR
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vehicle Color *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _vehicleColorController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'e.g., White, Black, Silver',
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
                      return 'Vehicle color is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// VEHICLE YEAR
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vehicle Year *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () async {
                    int? picked = await showModalBottomSheet<int>(
                      context: context,
                      builder: (BuildContext context) {
                        int tempYear = _selectedYear;
                        return SizedBox(
                          height: 300,
                          child: Column(
                            children: [
                              Expanded(
                                child: CupertinoPicker(
                                  itemExtent: 32,
                                  scrollController: FixedExtentScrollController(initialItem: DateTime.now().year - 1980),
                                  onSelectedItemChanged: (int index) {
                                    tempYear = 1980 + index;
                                  },
                                  children: List.generate(DateTime.now().year - 1979, (index) => Text((1980 + index).toString())),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(tempYear);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brandBlue,
                                    minimumSize: const Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Done'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedYear = picked;
                        _vehicleYearController.text = picked.toString();
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _vehicleYearController,
                      style: GoogleFonts.inter(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g., 2020',
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
                          return 'Vehicle year is required';
                        }
                        final year = int.tryParse(value);
                        if (year == null || year < 2000 || year > DateTime.now().year + 1) {
                          return 'Enter a valid year';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                /// BANKING DETAILS TITLE
                Text(
                  'Banking Information',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                /// BANK NAME
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bank Name *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _bankNameController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your bank name',
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
                      return 'Bank name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// ACCOUNT NUMBER
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account Number *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your account number',
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
                      return 'Account number is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// IFSC CODE
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'IFSC Code *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _ifscCodeController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter IFSC code',
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
                      return 'IFSC code is required';
                    }
                    if (value.length != 11) {
                      return 'IFSC code must be 11 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// ADDRESS
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Address *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _addressController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your full address',
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
                      return 'Address is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// STATE
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'State *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _stateController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your state',
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
                      return 'State is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// CITY
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'City *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your city',
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
                      return 'City is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// PINCODE
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pincode *',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter pincode',
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
                      return 'Pincode is required';
                    }
                    if (value.length != 6) {
                      return 'Pincode must be 6 digits';
                    }
                    return null;
                  },
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

                    /// SUBMIT BUTTON
                    Expanded(
                      child: Consumer<AuthProvider>(
                        builder: (_, auth, __) {
                          return SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _submit,
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
                                      'Submit',
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

                const SizedBox(height: 24),
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



