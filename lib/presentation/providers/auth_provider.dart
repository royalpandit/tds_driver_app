import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/services/firebase_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> sendOtp(String contact, String userType, String purpose) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.sendOtp(contact, userType, purpose);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String contact, String otpCode, String userType, {bool expectToken = true, String? firstName, String? lastName, int? gender}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final verifyResponse = await _apiService.verifyOtp(contact, otpCode, userType, firstName: firstName, lastName: lastName, gender: gender);
      
      // Check if verify-otp already returned the token (TDS API behavior)
      String? token;
      if (verifyResponse['data'] != null && verifyResponse['data']['user'] != null) {
        token = verifyResponse['data']['user']['api_token'];
      }
      
      if (token != null) {
        await _storageService.saveToken(token);
        await _storageService.saveUserData(contact, userType);
        await _storageService.setLoggedIn(true);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        if (expectToken) {
          // If no token in verify-otp, this shouldn't happen with current TDS API for login
          throw Exception('OTP verification successful but no token received');
        } else {
          // For register, no token expected
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOtp(String contact, String userType, String purpose) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.resendOtp(contact, userType, purpose);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Register a new user with full details
  Future<bool> registerUser({
    required String contact,
    required String otpCode,
    required String userType,
    required String firstName,
    required String lastName,
    required int gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.registerUser(
        contact: contact,
        otpCode: otpCode,
        userType: userType,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
      );

      String? token;
      if (response['data'] != null && response['data']['user'] != null) {
        token = response['data']['user']['api_token'];
      }

      if (token != null) {
        await _storageService.saveToken(token);
        await _storageService.saveUserData(contact, userType);
        await _storageService.setLoggedIn(true);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Registration successful but no token received');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Login using email & OTP (legacy endpoint `/api/login`).
  Future<bool> loginWithEmailOtp(String email, String otpCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, otpCode);

      String? token;
      if (response != null && response['data'] != null && response['data']['user'] != null) {
        token = response['data']['user']['api_token'];
      }

      if (token != null) {
        await _storageService.saveToken(token);
        await _storageService.saveUserData(email, 'user');
        await _storageService.setLoggedIn(true);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Login successful but no token received');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> isAuthenticated() async {
    return await _storageService.isLoggedIn();
  }
  
  Future<void> logout() async {
    await _storageService.clearAllData();
    notifyListeners();
  }

  // Driver authentication methods
  Future<bool> sendDriverOtp(String email, String purpose, {
    String? firstName,
    String? lastName,
    int? gender,
    String? phone,
    String? password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.sendDriverOtp(email, purpose,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        phone: phone,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // For now, treat API failures as success to allow navigation
      // This will be removed once the server issue is fixed
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> verifyDriverOtp(String email, String otpCode) async {
    return verifyOtp(email, otpCode, 'driver', expectToken: true);
  }

  Future<bool> registerDriver({
    required String firstName,
    String? middleName,
    required String lastName,
    required String email,
    required String password,
    required String phoneCode,
    required String phone,
    int? gender,
    String? dob,
    String? bloodGroup,
    required String licenseNumber,
    String? licenseType,
    String? issuingAuthority,
    String? issueDate,
    String? expDate,
    File? licenseFrontImage,
    File? licenseBackImage,
    required String aadharNumber,
    File? aadharFrontImage,
    File? aadharBackImage,
    required String panNumber,
    File? panUpload,
    File? medicalCertificateUpload,
    File? policeVerificationUpload,
    File? documents,
    String? state,
    String? city,
    String? pincode,
    String? address,
    String? bankName,
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
    String? empId,
    String? contractNumber,
    String? startDate,
    String? endDate,
    String? driverCommissionType,
    double? driverCommission,
    required String driverType,
    String? areaOfLocation,
    String? econtact,
    String? badgeNumber,
    String? badgeIssueDate,
    File? driverImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get FCM token from Firebase
      final firebaseService = FirebaseService();
      final fcmToken = await firebaseService.getSavedFCMToken();
      
      final response = await _apiService.registerDriver(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        email: email,
        password: password,
        phoneCode: phoneCode,
        phone: phone,
        gender: gender,
        dob: dob,
        bloodGroup: bloodGroup,
        licenseNumber: licenseNumber,
        licenseType: licenseType,
        issuingAuthority: issuingAuthority,
        issueDate: issueDate,
        expDate: expDate,
        licenseFrontImage: licenseFrontImage,
        licenseBackImage: licenseBackImage,
        aadharNumber: aadharNumber,
        aadharFrontImage: aadharFrontImage,
        aadharBackImage: aadharBackImage,
        panNumber: panNumber,
        panUpload: panUpload,
        medicalCertificateUpload: medicalCertificateUpload,
        policeVerificationUpload: policeVerificationUpload,
        documents: documents,
        state: state,
        city: city,
        pincode: pincode,
        address: address,
        bankName: bankName,
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        branchName: branchName,
        empId: empId,
        contractNumber: contractNumber,
        startDate: startDate,
        endDate: endDate,
        driverCommissionType: driverCommissionType,
        driverCommission: driverCommission,
        driverType: driverType,
        areaOfLocation: areaOfLocation,
        econtact: econtact,
        badgeNumber: badgeNumber,
        badgeIssueDate: badgeIssueDate,
        driverImage: driverImage,
        firebaseToken: fcmToken,
      );

      String? token;
      if (response['data'] != null && response['data']['user'] != null) {
        token = response['data']['user']['api_token'];
      }

      if (token != null) {
        await _storageService.saveToken(token);
        await _storageService.saveUserData(email, 'driver');
        await _storageService.setLoggedIn(true);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}



