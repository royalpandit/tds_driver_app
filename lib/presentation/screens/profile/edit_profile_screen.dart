import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/driver_provider.dart';
import '../../../data/models/driver_model.dart';
import '../../widgets/custom_popup_dropdown.dart';

// ============================================================================
// 1. CONSTANTS & THEME
// ============================================================================
class AppColors {
  static const Color darkPrimary = Color(0xFF1C5479);
  static const Color primary = Color(0xFF2E8BC0);
  static const Color lightPrimary = Color(0xFF4A90E2);
  static const Color background = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF2D3142);
  static const Color textGrey = Color(0xFF9C9EB9);
}

// ============================================================================
// 2. MAIN ENTRY POINT (for testing)
// ============================================================================
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: EditProfileScreen(),
      ),
    ),
  );
}

// ============================================================================
// 4. SCREEN UI
// ============================================================================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLLERS ---
  // Personal
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _areaLocCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  
  // Address
  final _addressCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  // License
  final _licenseNumCtrl = TextEditingController();
  final _licenseTypeCtrl = TextEditingController();
  final _issuingAuthCtrl = TextEditingController();
  final _issueDateCtrl = TextEditingController();
  final _expDateCtrl = TextEditingController();
  final _badgeNumCtrl = TextEditingController();
  final _badgeIssueDateCtrl = TextEditingController();

  // Identity
  final _aadharNumCtrl = TextEditingController();
  final _panNumCtrl = TextEditingController();

  // Bank
  final _bankNameCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();
  final _accountNumCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _branchNameCtrl = TextEditingController();

  // Employment
  final _empIdCtrl = TextEditingController();
  final _contractNumCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();
  final _commissionTypeCtrl = TextEditingController();

  // State
  String? _selectedGender;
  String? _selectedBloodGroup;
  
  // Image Files
  File? _driverImage;
  File? _licenseFront;
  File? _licenseBack;
  File? _aadharFront;
  File? _aadharBack;
  File? _panImage;

  bool _isDataPopulated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataPopulated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<DriverProvider>(context, listen: false).fetchDriverDetails();
      });
    }
  }

  void _populateData(DriverDetails data) {
    if (_isDataPopulated) return; // Don't overwrite edits

    _firstNameCtrl.text = data.personalInfo.firstName ;
    _middleNameCtrl.text = data.personalInfo.middleName ?? "";
    _lastNameCtrl.text = data.personalInfo.lastName ;
    _emailCtrl.text = data.personalInfo.email ;
    _phoneCtrl.text = data.personalInfo.phone ?? "";
    _dobCtrl.text = data.personalInfo.dob ?? "";
    _areaLocCtrl.text = data.personalInfo.areaOfLocation ?? "";
    _emergencyCtrl.text = data.emergencyInfo?.econtact ?? "";
    _selectedGender = data.personalInfo.gender?.toString();
    _selectedBloodGroup = data.personalInfo.bloodGroup;

    _addressCtrl.text = data.addressInfo?.address ?? "";
    _stateCtrl.text = data.addressInfo?.state ?? "";
    _cityCtrl.text = data.addressInfo?.city ?? "";
    _pincodeCtrl.text = data.addressInfo?.pincode ?? "";

    _licenseNumCtrl.text = data.licenseInfo?.licenseNumber ?? "";
    _licenseTypeCtrl.text = data.licenseInfo?.licenseType ?? "";
    _issuingAuthCtrl.text = data.licenseInfo?.issuingAuthority ?? "";
    _issueDateCtrl.text = data.licenseInfo?.issueDate ?? "";
    _expDateCtrl.text = data.licenseInfo?.expDate ?? "";
    _badgeNumCtrl.text = data.licenseInfo?.badgeNumber ?? "";
    _badgeIssueDateCtrl.text = data.licenseInfo?.badgeIssueDate ?? "";

    _aadharNumCtrl.text = data.aadhaarPanInfo?.aadharNumber ?? "";
    _panNumCtrl.text = data.aadhaarPanInfo?.panNumber ?? "";

    _bankNameCtrl.text = data.bankInfo?.bankName ?? "";
    _accountHolderCtrl.text = data.bankInfo?.accountHolderName ?? "";
    _accountNumCtrl.text = data.bankInfo?.accountNumber ?? "";
    _ifscCtrl.text = data.bankInfo?.ifscCode ?? "";
    _branchNameCtrl.text = data.bankInfo?.branchName ?? "";

    _empIdCtrl.text = data.employmentInfo?.empId ?? "";
    _contractNumCtrl.text = data.employmentInfo?.contractNumber ?? "";
    _startDateCtrl.text = data.employmentInfo?.startDate ?? "";
    _endDateCtrl.text = data.employmentInfo?.endDate ?? "";
    _commissionCtrl.text = data.employmentInfo?.driverCommission?.toString() ?? "";
    _commissionTypeCtrl.text = data.employmentInfo?.driverCommissionType ?? "";

    _isDataPopulated = true;
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<DriverProvider>(context, listen: false);
    
    bool success = await provider.updateDriverDetails(
      firstName: _firstNameCtrl.text,
      middleName: _middleNameCtrl.text,
      lastName: _lastNameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      gender: _selectedGender != null ? int.tryParse(_selectedGender!) : null,
      dob: _dobCtrl.text,
      bloodGroup: _selectedBloodGroup,
      areaOfLocation: _areaLocCtrl.text,
      econtact: _emergencyCtrl.text,
      address: _addressCtrl.text,
      state: _stateCtrl.text,
      city: _cityCtrl.text,
      pincode: _pincodeCtrl.text,
      licenseNumber: _licenseNumCtrl.text,
      licenseType: _licenseTypeCtrl.text,
      issuingAuthority: _issuingAuthCtrl.text,
      issueDate: _issueDateCtrl.text,
      expDate: _expDateCtrl.text,
      badgeNumber: _badgeNumCtrl.text,
      badgeIssueDate: _badgeIssueDateCtrl.text,
      aadharNumber: _aadharNumCtrl.text,
      panNumber: _panNumCtrl.text,
      bankName: _bankNameCtrl.text,
      accountHolderName: _accountHolderCtrl.text,
      accountNumber: _accountNumCtrl.text,
      ifscCode: _ifscCtrl.text,
      branchName: _branchNameCtrl.text,
      empId: _empIdCtrl.text,
      contractNumber: _contractNumCtrl.text,
      startDate: _startDateCtrl.text,
      endDate: _endDateCtrl.text,
      driverCommission: double.tryParse(_commissionCtrl.text),
      driverCommissionType: _commissionTypeCtrl.text,
    );
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, provider, child) {
        if (provider.driverDetails != null) _populateData(provider.driverDetails!);

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.darkPrimary, AppColors.primary, AppColors.lightPrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // HEADER
                _buildHeader(),

                // MAIN CONTENT CARD
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: provider.isLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : Column(
                          children: [
                            _buildProgressIndicator(),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: Form(
                                  key: _formKey,
                                  child: _buildStepContent(),
                                ),
                              ),
                            ),
                            _buildBottomButtons(),
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Text(
                "Edit Profile",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 40),
            ],
          ),
          Text(
            "Update your personal details",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(0, "Personal"),
          _buildStepLine(0),
          _buildStepCircle(1, "Docs"),
          _buildStepLine(1),
          _buildStepCircle(2, "Bank/Job"),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool active = _currentStep == step;
    bool done = _currentStep > step;
    return Column(
      children: [
        Container(
          width: 35, height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active || done ? AppColors.primary : Colors.grey[300],
            boxShadow: active ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
          ),
          child: Center(
            child: done 
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text("${step + 1}", style: GoogleFonts.poppins(color: active ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.w500, color: active ? AppColors.darkPrimary : Colors.grey)),
      ],
    );
  }

  Widget _buildStepLine(int index) {
    return Container(
      width: 40, height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      color: _currentStep > index ? AppColors.primary : Colors.grey[300],
    );
  }

  // --- CONTENT ---
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      default: return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        // Driver Image
        Center(
          child: GestureDetector(
            onTap: () => _showImagePicker((f) => setState(() => _driverImage = f)),
            child: Stack(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    image: _driverImage != null 
                      ? DecorationImage(image: FileImage(_driverImage!), fit: BoxFit.cover)
                      : const DecorationImage(image: NetworkImage("https://i.pravatar.cc/300"), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.darkPrimary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        _sectionTitle("Personal Information"),
        Row(
          children: [
            Expanded(child: _inputField(_firstNameCtrl, "First Name", Ionicons.person_outline, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'First name is required';
              }
              return null;
            })),
            const SizedBox(width: 15),
            Expanded(child: _inputField(_middleNameCtrl, "Middle Name", Ionicons.person_outline)),
          ],
        ),
        _inputField(_lastNameCtrl, "Last Name", Ionicons.person_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Last name is required';
          }
          return null;
        }),
        _inputField(_emailCtrl, "Email", Ionicons.mail_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Enter a valid email address';
          }
          return null;
        }),
        _inputField(_phoneCtrl, "Phone", Ionicons.call_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Phone number is required';
          }
          if (value.length < 10) {
            return 'Enter a valid phone number';
          }
          return null;
        }),
        
        Row(
          children: [
            Expanded(child: _dateField(_dobCtrl, "DOB")),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: CustomPopupDropdown(
                  value: _selectedGender == "1" ? "Male" : _selectedGender == "0" ? "Female" : null,
                  items: ["Male", "Female"],
                  hintText: "Select Gender",
                  onChanged: (value) => setState(() => _selectedGender = value == "Male" ? "1" : value == "Female" ? "0" : null),
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: CustomPopupDropdown(
            value: _selectedBloodGroup,
            items: ["A+", "B+", "O+", "AB+", "A-", "B-", "O-", "AB-"],
            hintText: "Select Blood Group",
            onChanged: (value) => setState(() => _selectedBloodGroup = value),
            fillColor: Colors.grey.shade100,
          ),
        ),
        _inputField(_emergencyCtrl, "Emergency Contact", Ionicons.warning_outline),

        const SizedBox(height: 20),
        _sectionTitle("Address Details"),
        _inputField(_addressCtrl, "Address", Ionicons.home_outline, lines: 2, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Address is required';
          }
          return null;
        }),
        Row(
          children: [
            Expanded(child: _inputField(_cityCtrl, "City", Ionicons.location_outline, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'City is required';
              }
              return null;
            })),
            const SizedBox(width: 15),
            Expanded(child: _inputField(_pincodeCtrl, "Pincode", Ionicons.pin_outline, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pincode is required';
              }
              if (value.length != 6) {
                return 'Enter a valid 6-digit pincode';
              }
              return null;
            })),
          ],
        ),
        _inputField(_stateCtrl, "State", Ionicons.map_outline),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        _sectionTitle("License Information"),
        _inputField(_licenseNumCtrl, "License Number", Ionicons.card_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'License number is required';
          }
          return null;
        }),
        _inputField(_licenseTypeCtrl, "License Type", Ionicons.car_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'License type is required';
          }
          return null;
        }),
        _inputField(_issuingAuthCtrl, "Issuing Authority", Ionicons.business_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Issuing authority is required';
          }
          return null;
        }),
        Row(
          children: [
            Expanded(child: _dateField(_issueDateCtrl, "Issue Date")),
            const SizedBox(width: 15),
            Expanded(child: _dateField(_expDateCtrl, "Expiry Date")),
          ],
        ),
        _inputField(_badgeNumCtrl, "Badge Number", Ionicons.id_card_outline),
        _dateField(_badgeIssueDateCtrl, "Badge Issue Date"),

        const SizedBox(height: 15),
        _label("License Photos"),
        Row(
          children: [
            Expanded(child: _imageUploadBox("Front", _licenseFront, (f) => setState(() => _licenseFront = f))),
            const SizedBox(width: 15),
            Expanded(child: _imageUploadBox("Back", _licenseBack, (f) => setState(() => _licenseBack = f))),
          ],
        ),

        const SizedBox(height: 25),
        _sectionTitle("Identity Proof"),
        _inputField(_aadharNumCtrl, "Aadhaar Number", Ionicons.finger_print_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Aadhaar number is required';
          }
          if (value.length != 12) {
            return 'Enter a valid 12-digit Aadhaar number';
          }
          return null;
        }),
        _label("Aadhaar Photos"),
        Row(
          children: [
            Expanded(child: _imageUploadBox("Front", _aadharFront, (f) => setState(() => _aadharFront = f))),
            const SizedBox(width: 15),
            Expanded(child: _imageUploadBox("Back", _aadharBack, (f) => setState(() => _aadharBack = f))),
          ],
        ),
        const SizedBox(height: 15),
        _inputField(_panNumCtrl, "PAN Number", Ionicons.card_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'PAN number is required';
          }
          final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
          if (!panRegex.hasMatch(value.toUpperCase())) {
            return 'Enter a valid PAN number';
          }
          return null;
        }),
        SizedBox(
          width: 150,
          child: _imageUploadBox("Upload PAN", _panImage, (f) => setState(() => _panImage = f)),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _sectionTitle("Bank Details"),
        _inputField(_bankNameCtrl, "Bank Name", Ionicons.business_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bank name is required';
          }
          return null;
        }),
        _inputField(_accountHolderCtrl, "Account Holder", Ionicons.person_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Account holder name is required';
          }
          return null;
        }),
        _inputField(_accountNumCtrl, "Account Number", Ionicons.wallet_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Account number is required';
          }
          if (value.length < 9) {
            return 'Enter a valid account number';
          }
          return null;
        }),
        _inputField(_ifscCtrl, "IFSC Code", Ionicons.code_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'IFSC code is required';
          }
          final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
          if (!ifscRegex.hasMatch(value.toUpperCase())) {
            return 'Enter a valid IFSC code';
          }
          return null;
        }),
        _inputField(_branchNameCtrl, "Branch", Ionicons.git_branch_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Branch name is required';
          }
          return null;
        }),

        const SizedBox(height: 25),
        _sectionTitle("Employment"),
        _inputField(_empIdCtrl, "Employee ID", Ionicons.id_card_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Employee ID is required';
          }
          return null;
        }),
        _inputField(_contractNumCtrl, "Contract Number", Ionicons.document_text_outline, validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Contract number is required';
          }
          return null;
        }),
        Row(
          children: [
            Expanded(child: _dateField(_startDateCtrl, "Start Date")),
            const SizedBox(width: 15),
            Expanded(child: _dateField(_endDateCtrl, "End Date")),
          ],
        ),
        Row(
          children: [
            Expanded(child: _inputField(_commissionCtrl, "Commission", Ionicons.cash_outline)),
            const SizedBox(width: 15),
            Expanded(child: _inputField(_commissionTypeCtrl, "Type", Ionicons.options_outline)),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("Back", style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.w600)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < _totalSteps - 1) {
                  setState(() => _currentStep++);
                } else {
                  _handleSubmit();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 5,
                shadowColor: AppColors.lightPrimary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _currentStep == _totalSteps - 1 ? "Save Profile" : "Next Step",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15, top: 5),
        child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkPrimary)),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(text, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label, IconData icon, {TextInputType? type, int lines = 1, String? Function(String?)? validator}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: lines,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5)),
        ),
        validator: validator,
      ),
    );
  }

  Widget _dateField(TextEditingController controller, String label) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            DateTime selectedDate = DateTime.tryParse(controller.text) ?? DateTime.now();
            return Container(
              height: 250,
              color: Colors.white,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selectedDate,
                minimumDate: DateTime(1900),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (DateTime newDate) {
                  controller.text = "${newDate.year}-${newDate.month.toString().padLeft(2,'0')}-${newDate.day.toString().padLeft(2,'0')}";
                },
              ),
            );
          },
        );
      },
      child: AbsorbPointer(child: _inputField(controller, label, Ionicons.calendar_outline)),
    );
  }






  Widget _imageUploadBox(String label, File? file, Function(File?) onPicked) {
    return GestureDetector(
      onTap: () => _showImagePicker(onPicked),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: file != null
          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(file, fit: BoxFit.cover))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.lightPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Ionicons.cloud_upload_outline, color: AppColors.primary, size: 20),
                ),
                const SizedBox(height: 8),
                Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
      ),
    );
  }

  void _showImagePicker(Function(File?) onPicked) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Ionicons.camera), title: Text("Camera", style: GoogleFonts.poppins()), onTap: () async {
              Navigator.pop(context);
              final img = await _picker.pickImage(source: ImageSource.camera);
              if (img != null) onPicked(File(img.path));
            }),
            ListTile(leading: const Icon(Ionicons.image), title: Text("Gallery", style: GoogleFonts.poppins()), onTap: () async {
              Navigator.pop(context);
              final img = await _picker.pickImage(source: ImageSource.gallery);
              if (img != null) onPicked(File(img.path));
            }),
          ],
        ),
      ),
    );
  }
}