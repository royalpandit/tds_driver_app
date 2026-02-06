import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';
import '../../data/services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DriverDetails? _driverDetails;
  DriverDetails? get driverDetails => _driverDetails;

  // For backward compatibility
  User? get user => _driverDetails != null ? User(
    id: _driverDetails!.personalInfo.id,
    name: '${_driverDetails!.personalInfo.firstName} ${_driverDetails!.personalInfo.middleName ?? ''} ${_driverDetails!.personalInfo.lastName}',
    email: _driverDetails!.personalInfo.email,
    phone: _driverDetails!.personalInfo.phone ?? '',
    userType: 'driver',
  ) : null;

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _driverDetails = await _apiService.getDriverDetails();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? phone,
    String? dob,
    String? bloodGroup,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.updateDriverDetails(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        email: email,
        phone: phone,
        dob: dob,
        bloodGroup: bloodGroup,
      );

      if (success) {
        // Refresh profile data
        await fetchUserProfile();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearUser() {
    _driverDetails = null;
    notifyListeners();
  }
}

// Backward compatibility class
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String userType;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
  });
}



