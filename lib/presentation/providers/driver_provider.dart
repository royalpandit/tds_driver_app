import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/api_service.dart';

class DriverProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DriverDetails? _driverDetails;
  DriverDetails? get driverDetails => _driverDetails;

  List<RideRequestOffer> _rideRequests = [];
  List<RideRequestOffer> get rideRequests => _rideRequests;

  List<RideRequestOffer> _pendingRideRequests = [];
  List<RideRequestOffer> get pendingRideRequests => _pendingRideRequests;

  List<RideRequestOffer> _acceptedRideRequests = [];
  List<RideRequestOffer> get acceptedRideRequests => _acceptedRideRequests;

  List<RideRequestOffer> _rejectedRideRequests = [];
  List<RideRequestOffer> get rejectedRideRequests => _rejectedRideRequests;

  List<Trip> _trips = [];
  List<Trip> get trips => _trips;

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  List<Map<String, dynamic>> _fuelHistory = [];
  List<Map<String, dynamic>> get fuelHistory => _fuelHistory;

  Map<String, dynamic> _dashboardStats = {
    'trip_stats': {
      'total_trips': 0,
      'upcoming_trips': 0,
      'planned_trips': 0,
      'running_trips': 0,
      'completed_trips': 0,
      'pending_offers': 0,
    },
    'today_activity': {
      'today_completed': 0,
      'today_planned': 0,
      'today_progress': 0,
    },
    'fuel_history': [],
    'location': {
      'status': 'No location recorded',
      'lat': null,
      'lng': null,
    },
  };
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  // Fetch driver details
  Future<bool> fetchDriverDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _driverDetails = await _apiService.getDriverDetails();
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

  // Update driver details
  Future<bool> updateDriverDetails({
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? password,
    String? phoneCode,
    String? phone,
    int? gender,
    String? dob,
    String? bloodGroup,
    String? licenseNumber,
    String? licenseType,
    String? issuingAuthority,
    String? issueDate,
    String? expDate,
    dynamic licenseFrontImage,
    dynamic licenseBackImage,
    String? aadharNumber,
    dynamic aadharFrontImage,
    dynamic aadharBackImage,
    String? panNumber,
    dynamic panUpload,
    dynamic medicalCertificateUpload,
    dynamic policeVerificationUpload,
    dynamic documents,
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
    String? driverType,
    String? areaOfLocation,
    String? econtact,
    String? badgeNumber,
    String? badgeIssueDate,
    dynamic driverImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.updateDriverDetails(
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
      );

      // Refresh driver details after update
      await fetchDriverDetails();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch ride requests
  Future<bool> fetchRideRequests({String? status, int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rideRequests = await _apiService.getDriverRideRequests(
        status: status,
        page: page,
      );
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

  // Fetch pending ride requests
  Future<bool> fetchPendingRideRequests({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingRideRequests = await _apiService.getDriverRideRequests(
        status: 'pending',
        page: page,
      );
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

  // Fetch accepted ride requests
  Future<bool> fetchAcceptedRideRequests({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _acceptedRideRequests = await _apiService.getDriverRideRequests(
        status: 'accepted',
        page: page,
      );
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

  // Fetch rejected ride requests
  Future<bool> fetchRejectedRideRequests({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rejectedRideRequests = await _apiService.getDriverRideRequests(
        status: 'rejected',
        page: page,
      );
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

  // Get ride request details
  Future<RideRequestOffer?> getRideRequestDetails(int offerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final details = await _apiService.getDriverRideRequestDetails(offerId);
      _isLoading = false;
      notifyListeners();
      return details;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Respond to ride request
  Future<bool> respondToRideRequest(int offerId, String action, {String? otp}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.respondToRideRequest(offerId, action, otp: otp);

      // Refresh ride requests after response
      await fetchPendingRideRequests();
      if (action == 'accept') {
        await fetchAcceptedRideRequests();
      } else if (action == 'reject') {
        await fetchRejectedRideRequests();
      }
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  Future<bool> acceptRideStep1(int offerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.respondToRideRequest(offerId, 'accept');

      _isLoading = false;
      notifyListeners();
      return true; // OTP popup open karne ke liye
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  Future<bool> acceptRideWithOtp(int offerId, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.respondToRideRequest(
        offerId,
        'accept',
        otp: otp,
      );

      await fetchPendingRideRequests();
      await fetchAcceptedRideRequests();

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

  // Fetch trips
  Future<bool> fetchTrips({int? page, int? perPage}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trips = await _apiService.getTrips(
        page: page,
        perPage: perPage,
      );
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

  // Get trip details
  Future<TripDetails?> getTripDetails(int tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final details = await _apiService.getTripDetails(tripId);
      _isLoading = false;
      notifyListeners();
      return details;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateTripStatus(int tripId, String status, {String? otp, String? cancelReason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.updateTripStatus(tripId, status, otp: otp, cancelReason: cancelReason);
      
      // Refresh trips after status update
      await fetchTrips();
      
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

  Future<Map<String, dynamic>?> verifyOtp(int? tripId, String otp, {int? passengerId, int? rideRequestId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.verifyTripOtp(tripId, otp, passengerId: passengerId, rideRequestId: rideRequestId);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Fetch expenses
  Future<bool> fetchExpenses({String? category, int? page, int? perPage}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _apiService.getDriverExpenses(
        category: category,
        page: page,
        perPage: perPage,
      );
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

  // Fetch dashboard stats
  Future<bool> fetchDashboardStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardStats = await _apiService.getDriverDashboardStats();
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

  // Fetch fuel history
  Future<bool> fetchFuelHistory({
    int? vehicleId,
    String? fromDate,
    String? toDate,
    int? perPage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _fuelHistory = await _apiService.getFuelHistory(
        vehicleId: vehicleId,
        fromDate: fromDate,
        toDate: toDate,
        perPage: perPage,
      );
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

  // Add fuel entry
  Future<bool> addFuelEntry({
    required int vehicleId,
    required double startMeter,
    required double qty,
    required double costPerUnit,
    required String date,
    String? fuelFrom,
    int? fuelStationId,
    int? fuelTypeId,
    String? reference,
    String? note,
    bool? complete,
    dynamic image,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.addFuelEntry(
        vehicleId: vehicleId,
        startMeter: startMeter,
        qty: qty,
        costPerUnit: costPerUnit,
        date: date,
        fuelFrom: fuelFrom,
        fuelStationId: fuelStationId,
        fuelTypeId: fuelTypeId,
        reference: reference,
        note: note,
        complete: complete,
        image: image,
      );
      
      // Refresh fuel history after successful addition
      await fetchFuelHistory();
      
      // Also refresh dashboard stats to update fuel history there
      await fetchDashboardStats();
      
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

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}



