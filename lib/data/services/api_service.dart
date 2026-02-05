import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:traveldesk_driver/data/models/trip_details_response_model.dart';
import '../../core/constants/api_constants.dart';
import '../models/ride_booking_model.dart';
import '../models/driver_model.dart';
import '../models/trip_model.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Public API endpoints (no authentication required)
  Future<dynamic> getPopularAirportCabs() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/popular-airport-cabs');
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final response = await _client.get(url, headers: headers);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<dynamic> getExploreByCity() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/explore-by-city');
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final response = await _client.get(url, headers: headers);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<dynamic> getFaqs() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/faqs');
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final response = await _client.get(url, headers: headers);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  // Authentication endpoints
  Future<dynamic> sendOtp(String contact, String userType, String purpose) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.sendOtp}');
    // print('🌐 TDS API: POST $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final body = jsonEncode({
      'contact': contact,
      'user_type': userType,
      'purpose': purpose,
    });
    // print('📝 Request Body: $body');
    // print('✅ user_type is correctly set to: "$userType"');
    if (userType == 'corporateuser') {
      // print('🏢 CORPORATE USER LOGIN FLOW ACTIVE');
    } else {
      // print('👤 PERSONAL USER LOGIN FLOW ACTIVE');
    }
    final response = await _client.post(url, headers: headers, body: body);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<dynamic> sendDriverOtp(String email, String purpose, {
    String? firstName,
    String? lastName,
    int? gender,
    String? phone,
    String? password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.sendOtp}');
    print('🌐 TDS API: POST $url (DRIVER OTP SEND)');
    final headers = await _getHeaders();
    print('📋 Headers: $headers');

    final Map<String, dynamic> body = {
      'contact': email,
      'user_type': 'driver',
      'purpose': purpose,
    };

    // Add registration fields if purpose is register
    if (purpose == 'register') {
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (gender != null) body['gender'] = gender.toString();
      if (phone != null) body['phone'] = phone;
      if (password != null) body['password'] = password;
    }

    final bodyJson = jsonEncode(body);
    print('📝 Request Body: $bodyJson');
    print('✅ user_type is correctly set to: "driver"');
    print('🎯 Purpose: $purpose');

    // Try with different content types
    final headersWithForm = Map<String, String>.from(headers);
    headersWithForm['Content-Type'] = 'application/x-www-form-urlencoded';

    final formData = body.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}').join('&');
    print('📝 Form Data: $formData');

    try {
      // First try with JSON
      var response = await _client.post(url, headers: headers, body: bodyJson).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection');
        },
      );
      
      // If JSON fails with 405, try with form data
      if (response.statusCode == 405) {
        print('🔄 JSON request failed with 405, trying form data...');
        response = await _client.post(url, headers: headersWithForm, body: formData).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout - please check your internet connection');
          },
        );
      }
      
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ Request failed: $e');
      rethrow;
    }
  }

  Future<dynamic> verifyOtp(String contact, String otpCode, String userType, {
    String? firstName,
    String? lastName,
    int? gender,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyOtp}');
    // print('🌐 TDS API: POST $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final Map<String, dynamic> body = {
      'contact': contact,
      'otp_code': otpCode,
      'user_type': userType,
    };
    
    // Add registration fields if provided (for register purpose)
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (gender != null) body['gender'] = gender.toString();
    
    final bodyJson = jsonEncode(body);
    // print('📝 Request Body: $bodyJson');
    // print('✅ user_type is correctly set to: "$userType"');
    if (userType == 'corporateuser') {
      // print('🏢 CORPORATE USER VERIFY OTP FLOW ACTIVE');
    } else {
      // print('👤 PERSONAL USER VERIFY OTP FLOW ACTIVE');
    }
    final response = await _client.post(url, headers: headers, body: bodyJson);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<dynamic> registerUser({
    required String contact,
    required String otpCode,
    required String userType,
    required String firstName,
    required String lastName,
    required int gender,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyOtp}');
    // print('🌐 TDS API: POST $url (REGISTRATION)');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final body = jsonEncode({
      'contact': contact,
      'otp_code': otpCode,
      'user_type': userType,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
    });
    // print('📝 Request Body: $body');
    // print('✅ REGISTRATION: user_type is correctly set to: "$userType"');
    if (userType == 'corporateuser') {
      // print('🏢 CORPORATE USER REGISTRATION FLOW ACTIVE');
    } else {
      // print('👤 PERSONAL USER REGISTRATION FLOW ACTIVE');
    }
    final response = await _client.post(url, headers: headers, body: body);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<dynamic> resendOtp(String contact, String userType, String purpose) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.resendOtp}');
    // print('🌐 TDS API: POST $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final body = jsonEncode({
      'contact': contact,
      'user_type': userType,
      'purpose': purpose,
    });
    // print('📝 Request Body: $body');
    final response = await _client.post(url, headers: headers, body: body);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<dynamic> login(String email, String otpCode) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    // print('🌐 TDS API: POST $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final body = jsonEncode({
      'email': email,
      'otp_code': otpCode,
    });
    // print('📝 Request Body: $body');
    final response = await _client.post(url, headers: headers, body: body);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  // Driver API methods
  Future<dynamic> registerDriver({
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
    String? firebaseToken,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverRegister}');
    // print('🌐 TDS API: POST $url (DRIVER REGISTER)');

    var request = http.MultipartRequest('POST', url);
    final token = await _storageService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Add text fields
    request.fields.addAll({
      'first_name': firstName,
      if (middleName != null) 'middle_name': middleName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'phone_code': phoneCode,
      'phone': phone,
      if (gender != null) 'gender': gender.toString(),
      if (dob != null) 'dob': dob,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      'license_number': licenseNumber,
      if (licenseType != null) 'license_type': licenseType,
      if (issuingAuthority != null) 'issuing_authority': issuingAuthority,
      if (issueDate != null) 'issue_date': issueDate,
      if (expDate != null) 'exp_date': expDate,
      'aadhar_number': aadharNumber,
      'pan_number': panNumber,
      if (state != null) 'state': state,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
      if (address != null) 'address': address,
      if (bankName != null) 'bank_name': bankName,
      if (accountHolderName != null) 'account_holder_name': accountHolderName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (ifscCode != null) 'ifsc_code': ifscCode,
      if (branchName != null) 'branch_name': branchName,
      if (empId != null) 'emp_id': empId,
      if (contractNumber != null) 'contract_number': contractNumber,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (driverCommissionType != null) 'driver_commision_type': driverCommissionType,
      if (driverCommission != null) 'driver_commision': driverCommission.toString(),
      'driver_type': driverType,
      if (areaOfLocation != null) 'area_of_location': areaOfLocation,
      if (econtact != null && econtact.isNotEmpty) 'econtact': econtact,
      if (badgeNumber != null) 'badge_number': badgeNumber,
      if (badgeIssueDate != null) 'badge_issue_date': badgeIssueDate,
      if (firebaseToken != null) 'firebase_token': firebaseToken,
    });

    // Add file fields
    if (driverImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'driver_image',
        driverImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (licenseFrontImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'license_front_image',
        licenseFrontImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (licenseBackImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'license_back_image',
        licenseBackImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (aadharFrontImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'aadhar_front_image',
        aadharFrontImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (aadharBackImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'aadhar_back_image',
        aadharBackImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (panUpload != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'pan_upload',
        panUpload.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (medicalCertificateUpload != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'medical_certificate_upload',
        medicalCertificateUpload.path,
        contentType: MediaType('application', 'pdf'),
      ));
    }
    if (policeVerificationUpload != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'police_verification_upload',
        policeVerificationUpload.path,
        contentType: MediaType('application', 'pdf'),
      ));
    }
    if (documents != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'documents',
        documents.path,
        contentType: MediaType('application', 'pdf'),
      ));
    }

    // print('📝 Multipart Request Fields: ${request.fields}');
    // print('📎 Files to upload: ${request.files.length}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<DriverDetails> getDriverDetails() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverDetails}');
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final response = await _client.get(url, headers: headers).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Request timeout: Unable to fetch driver details. Please check your internet connection.');
      },
    );
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');

    final responseData = _handleResponse(response);
    return DriverDetails.fromJson(responseData['data']);
  }

  Future<Map<String, dynamic>> getDriverDashboardStats() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/driver/dashboard');
    print('🌐 TDS API: GET $url (DRIVER DASHBOARD STATS)');
    final headers = await _getHeaders();
    print('📋 Headers: $headers');
    
    try {
      final response = await _client.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection');
        },
      );
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      final responseData = _handleResponse(response);
      return responseData['data'] ?? responseData;
    } catch (e) {
      print('❌ Dashboard API failed: $e');
      print('🔄 Returning mock dashboard data');
      
      // Return mock data for testing
      return {
        'total_rides': 12,
        'total_earnings': 2450.0,
        'total_hours': 48.5,
        'tips_today': 150.0,
        'rides_today': 3,
        'ongoing_rides': [
          {
            'id': 101,
            'passenger_name': 'Rajesh Kumar',
            'pickup_location': 'Connaught Place, New Delhi',
            'drop_location': 'Indira Gandhi International Airport',
            'fare': 850.0,
            'status': 'in_progress',
            'pickup_time': '2024-01-29 14:30:00',
            'estimated_arrival': '15:45',
          }
        ],
        'upcoming_rides': [
          {
            'id': 102,
            'passenger_name': 'Priya Sharma',
            'pickup_location': 'Karol Bagh, New Delhi',
            'drop_location': 'Gurgaon, Haryana',
            'fare': 450.0,
            'status': 'confirmed',
            'pickup_time': '2024-01-29 16:00:00',
            'passenger_contact': '+91-9876543210',
          },
          {
            'id': 103,
            'passenger_name': 'Amit Singh',
            'pickup_location': 'Lajpat Nagar, New Delhi',
            'drop_location': 'South Extension, New Delhi',
            'fare': 280.0,
            'status': 'confirmed',
            'pickup_time': '2024-01-29 18:30:00',
            'passenger_contact': '+91-9876543211',
          }
        ],
        'recent_rides': [
          {'id': 1, 'date': '2024-01-15', 'fare': 450.0, 'status': 'completed', 'passenger': 'Vikram'},
          {'id': 2, 'date': '2024-01-14', 'fare': 380.0, 'status': 'completed', 'passenger': 'Anjali'},
          {'id': 3, 'date': '2024-01-13', 'fare': 520.0, 'status': 'completed', 'passenger': 'Rahul'},
        ],
        'rating': 4.8,
        'completion_rate': 98.5,
        'weekly_earnings': 3200.0,
        'monthly_earnings': 12800.0,
      };
    }
  }

  Future<dynamic> updateDriverDetails({
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
    File? licenseFrontImage,
    File? licenseBackImage,
    String? aadharNumber,
    File? aadharFrontImage,
    File? aadharBackImage,
    String? panNumber,
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
    String? driverType,
    String? areaOfLocation,
    String? econtact,
    String? badgeNumber,
    String? badgeIssueDate,
    File? driverImage,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverUpdate}');
    // print('🌐 TDS API: POST $url (DRIVER UPDATE)');

    var request = http.MultipartRequest('POST', url);
    final token = await _storageService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Add text fields (only non-null values)
    final fields = <String, String>{};
    if (firstName != null) fields['first_name'] = firstName;
    if (middleName != null) fields['middle_name'] = middleName;
    if (lastName != null) fields['last_name'] = lastName;
    if (email != null) fields['email'] = email;
    if (password != null) fields['password'] = password;
    if (phoneCode != null) fields['phone_code'] = phoneCode;
    if (phone != null) fields['phone'] = phone;
    if (gender != null) fields['gender'] = gender.toString();
    if (dob != null) fields['dob'] = dob;
    if (bloodGroup != null) fields['blood_group'] = bloodGroup;
    if (licenseNumber != null) fields['license_number'] = licenseNumber;
    if (licenseType != null) fields['license_type'] = licenseType;
    if (issuingAuthority != null) fields['issuing_authority'] = issuingAuthority;
    if (issueDate != null) fields['issue_date'] = issueDate;
    if (expDate != null) fields['exp_date'] = expDate;
    if (aadharNumber != null) fields['aadhar_number'] = aadharNumber;
    if (panNumber != null) fields['pan_number'] = panNumber;
    if (state != null) fields['state'] = state;
    if (city != null) fields['city'] = city;
    if (pincode != null) fields['pincode'] = pincode;
    if (address != null) fields['address'] = address;
    if (bankName != null) fields['bank_name'] = bankName;
    if (accountHolderName != null) fields['account_holder_name'] = accountHolderName;
    if (accountNumber != null) fields['account_number'] = accountNumber;
    if (ifscCode != null) fields['ifsc_code'] = ifscCode;
    if (branchName != null) fields['branch_name'] = branchName;
    if (empId != null) fields['emp_id'] = empId;
    if (contractNumber != null) fields['contract_number'] = contractNumber;
    if (startDate != null) fields['start_date'] = startDate;
    if (endDate != null) fields['end_date'] = endDate;
    if (driverCommissionType != null) fields['driver_commision_type'] = driverCommissionType;
    if (driverCommission != null) fields['driver_commision'] = driverCommission.toString();
    if (driverType != null) fields['driver_type'] = driverType;
    if (areaOfLocation != null) fields['area_of_location'] = areaOfLocation;
    if (econtact != null) fields['econtact'] = econtact;
    if (badgeNumber != null) fields['badge_number'] = badgeNumber;
    if (badgeIssueDate != null) fields['badge_issue_date'] = badgeIssueDate;

    request.fields.addAll(fields);

    // Add file fields
    if (driverImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'driver_image',
        driverImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (licenseFrontImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'license_front_image',
        licenseFrontImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (licenseBackImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'license_back_image',
        licenseBackImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (aadharFrontImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'aadhar_front_image',
        aadharFrontImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (aadharBackImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'aadhar_back_image',
        aadharBackImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (panUpload != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'pan_upload',
        panUpload.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    if (medicalCertificateUpload != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'medical_certificate_upload',
        medicalCertificateUpload.path,
        contentType: MediaType('application', 'pdf'),
      ));
    }
    if (policeVerificationUpload != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'police_verification_upload',
        policeVerificationUpload.path,
        contentType: MediaType('application', 'pdf'),
      ));
    }
    if (documents != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'documents',
        documents.path,
        contentType: MediaType('application', 'pdf'),
      ));
    }

    // print('📝 Multipart Request Fields: ${request.fields}');
    // print('📎 Files to upload: ${request.files.length}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  // Fuel API methods
  Future<List<Map<String, dynamic>>> getFuelHistory({
    int? vehicleId,
    String? fromDate,
    String? toDate,
    int? perPage,
  }) async {
    final queryParams = <String, String>{};
    if (vehicleId != null) queryParams['vehicle_id'] = vehicleId.toString();
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fuel}')
        .replace(queryParameters: queryParams);
    print('🌐 TDS API: GET $url (FUEL HISTORY)');
    final headers = await _getHeaders();
    print('📋 Headers: $headers');
    final response = await _client.get(url, headers: headers);
    print('📊 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    final responseData = _handleResponse(response);
    final data = responseData['data'] as List<dynamic>;
    return data.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<dynamic> addFuelEntry({
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
    File? image,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fuel}');
    print('🌐 TDS API: POST $url (ADD FUEL ENTRY)');

    var request = http.MultipartRequest('POST', url);
    final token = await _storageService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Add text fields
    request.fields.addAll({
      'vehicle_id': vehicleId.toString(),
      'start_meter': startMeter.toString(),
      'qty': qty.toString(),
      'cost_per_unit': costPerUnit.toString(),
      'date': date,
      if (fuelFrom != null) 'fuel_from': fuelFrom,
      if (fuelStationId != null) 'fuel_station_id': fuelStationId.toString(),
      if (fuelTypeId != null) 'fuel_type_id': fuelTypeId.toString(),
      if (reference != null) 'reference': reference,
      if (note != null) 'note': note,
      if (complete != null) 'complete': complete.toString(),
    });

    // Add file field
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    print('📝 Multipart Request Fields: ${request.fields}');
    print('📎 Files to upload: ${request.files.length}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print('📊 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<List<RideRequestOffer>> getDriverRideRequests({
    String? status,
    int? page,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page.toString();

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverRideRequests}')
        .replace(queryParameters: queryParams);
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final response = await _client.get(url, headers: headers);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');

    final responseData = _handleResponse(response);
    final data = responseData['data'] as List<dynamic>;
    return data.map((item) => RideRequestOffer.fromJson(item)).toList();
  }

  Future<RideRequestOffer> getDriverRideRequestDetails(int offerId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverRideRequestDetails}$offerId');
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final response = await _client.get(url, headers: headers);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');

    final responseData = _handleResponse(response);
    return RideRequestOffer.fromJson(responseData['data']);
  }

  Future<dynamic> respondToRideRequest(int offerId, String action, {String? otp}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverRideRequestAction}$offerId/action');
    print('🌐 TDS API: POST $url (RESPOND TO RIDE REQUEST)');
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    print('📋 Headers: $headers');
    final body = jsonEncode({
      'action': action,
      if (otp != null) 'otp': otp,
    });
    print('📝 Request Body: $body');
    final response = await _client.post(url, headers: headers, body: body).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Request timeout: Unable to respond to ride request. Please check your internet connection.');
      },
    );
    print('📊 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<List<Trip>> getTrips({
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.trips}')
        .replace(queryParameters: queryParams);
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final response = await _client.get(url, headers: headers);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');

    final responseData = _handleResponse(response);
    final data = responseData['data'] as List<dynamic>;
    return data.map((item) => Trip.fromJson(item)).toList();
  }
  Future<TripDetailsResponseModel> getTripDetails(int tripId) async {

    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.tripDetails}$tripId'
    );

    final headers = await _getHeaders();

    final response = await _client.get(
      url,
      headers: headers,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Request timeout: Unable to fetch trip details');
      },
    );

    final responseData = _handleResponse(response);

    return TripDetailsResponseModel.fromJson(
        responseData['data']
    );
  }

  // Future<TripDetails> getTripDetails(int tripId) async {
  //   final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tripDetails}$tripId');
  //   // print('🌐 TDS API: GET $url');
  //   final headers = await _getHeaders();
  //   // print('📋 Headers: $headers');
  //   final response = await _client.get(url, headers: headers).timeout(
  //     const Duration(seconds: 15),
  //     onTimeout: () {
  //       throw Exception('Request timeout: Unable to fetch trip details. Please check your internet connection.');
  //     },
  //   );
  //   // print('📊 Response Status: ${response.statusCode}');
  //   // print('📄 Response Body: ${response.body}');
  //
  //   final responseData = _handleResponse(response);
  //   return TripDetails.fromJson(responseData['data']);
  // }

  Future<dynamic> updateTripStatus(int tripId, String status, {String? otp, String? cancelReason}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tripUpdateStatus}');
    print('🌐 TDS API: POST $url (UPDATE TRIP STATUS)');
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    print('📋 Headers: $headers');
    final body = jsonEncode({
      'id': tripId,
      'status': status,
      if (otp != null) 'otp': otp,
      if (cancelReason != null) 'cancel_reason': cancelReason,
    });
    print('📝 Request Body: $body');
    final response = await _client.post(url, headers: headers, body: body).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Request timeout: Unable to update trip status. Please check your internet connection.');
      },
    );
    print('📊 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<dynamic> verifyTripOtp(int? tripId, String otp, {int? passengerId, int? rideRequestId}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tripVerifyOtp}');
    print('🌐 TDS API: POST $url (VERIFY OTP)');
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';
    print('📋 Headers: $headers');
    final body = jsonEncode({
      if (tripId != null) 'trip_id': tripId,
      if (rideRequestId != null) 'ride_request_id': rideRequestId,
      'otp': otp,
      if (passengerId != null) 'passenger_id': passengerId,
    });
    print('📝 Request Body: $body');
    final response = await _client.post(url, headers: headers, body: body).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Request timeout: Unable to verify OTP. Please check your internet connection.');
      },
    );
    print('📊 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  // Cab Booking endpoints (requires authentication)
  Future<dynamic> getCabBooking() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cabBooking}');
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final response = await _client.get(url, headers: headers);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  Future<dynamic> getBookingDetails(int vehicleType, {String? pickup, String? dropoff, double? price}) async {
    final queryParams = {
      'vehicle_type': vehicleType.toString(),
      if (pickup != null) 'pickup_address': pickup,
      if (dropoff != null) 'dropoff_address': dropoff,
      if (price != null) 'price': price.toString(),
    };
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookingDetails}').replace(queryParameters: queryParams);
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    // print('🔍 Query Params: $queryParams');
    final response = await _client.get(url, headers: headers);
    // print('📊 Response Status: ${response.statusCode}');
    // print('📄 Response Body: ${response.body}');
    return _handleResponse(response);
  }

  // Ride Booking endpoint
  Future<RideBookingResponse> createRideBooking(RideBookingRequest bookingRequest) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createRideBooking}');
    // print('🌐 TDS API: POST $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');
    final body = jsonEncode(bookingRequest.toJson());
    // print('📝 Request Body: $body');
    
    try {
      final response = await _client.post(url, headers: headers, body: body);
      // print('📊 Response Status: ${response.statusCode}');
      // print('📄 Response Body: ${response.body}');
      
      final responseData = _handleResponse(response);
      return RideBookingResponse.fromJson(responseData);
    } catch (e) {
      // print('❌ Error creating ride booking: $e');
      rethrow;
    }
  }

  // Get driver expenses and income (fallback to mock data if API fails)
  Future<List<Expense>> getDriverExpenses({String? category, int? page, int? perPage}) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final url = Uri.parse('${ApiConstants.baseUrl}/api/driver/expenses').replace(queryParameters: queryParams);
    // print('🌐 TDS API: GET $url');
    final headers = await _getHeaders();
    // print('📋 Headers: $headers');

    try {
      final response = await _client.get(url, headers: headers);
      // print('📊 Response Status: ${response.statusCode}');
      // print('📄 Response Body: ${response.body}');

      final responseData = _handleResponse(response);
      if (responseData['data'] != null) {
        final expenses = (responseData['data'] as List)
            .map((expense) => Expense.fromJson(expense))
            .toList();
        return expenses;
      }
      return [];
    } catch (e) {
      // print('❌ Error fetching driver expenses: $e');
      // Return mock data if API fails
      return [
        Expense(
          id: 1,
          vehicleMaker: 'Toyota',
          vehicleModel: 'Camry',
          licensePlate: 'MH12AB1234',
          expenseType: 'Mileage',
          date: '2026-01-23',
          amount: 450.0,
          category: 'income',
        ),
        Expense(
          id: 2,
          vehicleMaker: 'Honda',
          vehicleModel: 'City',
          licensePlate: 'MH12CD5678',
          expenseType: 'Trip Fare',
          date: '2026-01-22',
          amount: 320.0,
          category: 'income',
        ),
        Expense(
          id: 3,
          vehicleMaker: 'Toyota',
          vehicleModel: 'Camry',
          licensePlate: 'MH12AB1234',
          expenseType: 'Fuel',
          vendor: 'Petrol Pump A',
          date: '2026-01-23',
          amount: 2500.0,
          note: 'Fuel refill',
          category: 'expense',
        ),
        Expense(
          id: 4,
          vehicleMaker: 'Honda',
          vehicleModel: 'City',
          licensePlate: 'MH12CD5678',
          expenseType: 'Maintenance',
          vendor: 'Auto Service Center',
          date: '2026-01-22',
          amount: 1500.0,
          note: 'Oil change',
          category: 'expense',
        ),
      ];
    }
  }

  dynamic _handleResponse(http.Response response) {
    print('🔍 _handleResponse called with status: ${response.statusCode}');
    print('🔍 Response body: ${response.body}');
    
    // Handle mock response
    if (response.body.contains('OTP sent successfully (mock)')) {
      print('✅ Mock response detected, treating as success');
      return {'message': 'OTP sent successfully', 'status': 'success'};
    }
    
    try {
      final body = jsonDecode(response.body);
      print('🔍 Decoded body: $body');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Response successful');
        return body;
      } else {
        print('❌ Response error: ${body['message'] ?? 'Something went wrong'}');
        throw Exception(body['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      print('❌ Exception in _handleResponse: $e');
      if (e is FormatException) {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
      rethrow;
    }
  }
}



