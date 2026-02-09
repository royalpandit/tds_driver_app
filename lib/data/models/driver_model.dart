class Driver {
  final int id;
  final String name;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String? phone;
  final String? phoneCode;
  final int? gender;
  final String? dob;
  final String? bloodGroup;
  final String? driverType;
  final String? areaOfLocation;
  final String? empId;
  final String? contractNumber;
  final String? startDate;
  final String? endDate;
  final String? driverCommissionType;
  final double? driverCommission;
  final String? econtact;
  final String? badgeNumber;
  final String? badgeIssueDate;
  final String? status;
  final String? driverImageUrl;

  Driver({
    required this.id,
    required this.name,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    this.phone,
    this.phoneCode,
    this.gender,
    this.dob,
    this.bloodGroup,
    this.driverType,
    this.areaOfLocation,
    this.empId,
    this.contractNumber,
    this.startDate,
    this.endDate,
    this.driverCommissionType,
    this.driverCommission,
    this.econtact,
    this.badgeNumber,
    this.badgeIssueDate,
    this.status,
    this.driverImageUrl,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      phoneCode: json['phone_code'],
      gender: json['gender'] != null
          ? int.tryParse(json['gender'].toString())
          : null,
      dob: json['dob'],
      bloodGroup: json['blood_group'],
      driverType: json['driver_type'],
      areaOfLocation: json['area_of_location'],
      empId: json['emp_id'],
      contractNumber: json['contract_number'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      driverCommissionType: json['driver_commision_type'],
      driverCommission: json['driver_commision'] != null
          ? double.tryParse(json['driver_commision'].toString())
          : null,
      econtact: json['econtact'],
      badgeNumber: json['badge_number'],
      badgeIssueDate: json['badge_issue_date'],
      status: json['status'],
      driverImageUrl: json['driver_image_url'],
    );
  }
}

class DriverDetails {
  final Driver personalInfo;
  final AddressInfo? addressInfo;
  final BankInfo? bankInfo;
  final LicenseInfo? licenseInfo;
  final AadhaarPanInfo? aadhaarPanInfo;
  final EmploymentInfo? employmentInfo;
  final EmergencyInfo? emergencyInfo;
  final VehicleInfo? vehicleInfo; // ✅ NEW
  final Map<String, String?> documents;
  final String status;

  DriverDetails({
    required this.personalInfo,
    this.addressInfo,
    this.bankInfo,
    this.licenseInfo,
    this.aadhaarPanInfo,
    this.employmentInfo,
    this.emergencyInfo,
    this.vehicleInfo,
    required this.documents,
    required this.status,
  });

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      personalInfo: Driver.fromJson(json['personal_info'] ?? {}),
      addressInfo: json['address_info'] != null
          ? AddressInfo.fromJson(json['address_info'])
          : null,
      bankInfo: json['bank_info'] != null
          ? BankInfo.fromJson(json['bank_info'])
          : null,
      licenseInfo: json['license_info'] != null
          ? LicenseInfo.fromJson(json['license_info'])
          : null,
      aadhaarPanInfo: json['aadhaar_pan_info'] != null
          ? AadhaarPanInfo.fromJson(json['aadhaar_pan_info'])
          : null,
      employmentInfo: json['employment_info'] != null
          ? EmploymentInfo.fromJson(json['employment_info'])
          : null,
      emergencyInfo: json['emergency_info'] != null
          ? EmergencyInfo.fromJson(json['emergency_info'])
          : null,
      vehicleInfo: json['vehicle_info'] != null
          ? VehicleInfo.fromJson(json['vehicle_info'])
          : null,
      documents: Map<String, String?>.from(json['documents'] ?? {}),
      status: json['status'] ?? '',
    );
  }
}

class VehicleInfo {
  final int id;
  final String? makeName;
  final String? modelName;
  final String? licensePlate;
  final String? colorName;
  final String? year;
  final String? engineType;
  final String? vin;
  final int? mileage;
  final String? vehicleType;
  final String? vehicleImage;

  VehicleInfo({
    required this.id,
    this.makeName,
    this.modelName,
    this.licensePlate,
    this.colorName,
    this.year,
    this.engineType,
    this.vin,
    this.mileage,
    this.vehicleType,
    this.vehicleImage,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      id: json['id'] ?? 0,
      makeName: json['make_name'],
      modelName: json['model_name'],
      licensePlate: json['license_plate'],
      colorName: json['color_name'],
      year: json['year'],
      engineType: json['engine_type'],
      vin: json['vin'],
      mileage: json['mileage'] != null
          ? int.tryParse(json['mileage'].toString())
          : null,
      vehicleType: json['vehicle_type'],
      vehicleImage: json['vehicle_image'],
    );
  }
}

class AddressInfo {
  final String? state;
  final String? city;
  final String? pincode;
  final String? address;

  AddressInfo({
    this.state,
    this.city,
    this.pincode,
    this.address,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      address: json['address'],
    );
  }
}

class BankInfo {
  final String? bankName;
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;

  BankInfo({
    this.bankName,
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      bankName: json['bank_name'],
      accountHolderName: json['account_holder_name'],
      accountNumber: json['account_number'],
      ifscCode: json['ifsc_code'],
      branchName: json['branch_name'],
    );
  }
}

class LicenseInfo {
  final String? licenseNumber;
  final String? licenseType;
  final String? issuingAuthority;
  final String? issueDate;
  final String? expDate;
  final String? badgeNumber;
  final String? badgeIssueDate;

  LicenseInfo({
    this.licenseNumber,
    this.licenseType,
    this.issuingAuthority,
    this.issueDate,
    this.expDate,
    this.badgeNumber,
    this.badgeIssueDate,
  });

  factory LicenseInfo.fromJson(Map<String, dynamic> json) {
    return LicenseInfo(
      licenseNumber: json['license_number'],
      licenseType: json['license_type'],
      issuingAuthority: json['issuing_authority'],
      issueDate: json['issue_date'],
      expDate: json['exp_date'],
      badgeNumber: json['badge_number'],
      badgeIssueDate: json['badge_issue_date'],
    );
  }
}

class AadhaarPanInfo {
  final String? aadharNumber;
  final String? panNumber;

  AadhaarPanInfo({
    this.aadharNumber,
    this.panNumber,
  });

  factory AadhaarPanInfo.fromJson(Map<String, dynamic> json) {
    return AadhaarPanInfo(
      aadharNumber: json['aadhar_number'],
      panNumber: json['pan_number'],
    );
  }
}

class EmploymentInfo {
  final String? empId;
  final String? contractNumber;
  final String? startDate;
  final String? endDate;
  final String? driverCommissionType;
  final double? driverCommission;

  EmploymentInfo({
    this.empId,
    this.contractNumber,
    this.startDate,
    this.endDate,
    this.driverCommissionType,
    this.driverCommission,
  });

  factory EmploymentInfo.fromJson(Map<String, dynamic> json) {
    return EmploymentInfo(
      empId: json['emp_id'],
      contractNumber: json['contract_number'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      driverCommissionType: json['driver_commision_type'],
      driverCommission: json['driver_commision'] != null
          ? double.tryParse(json['driver_commision'].toString())
          : null,
    );
  }
}

class EmergencyInfo {
  final String? econtact;

  EmergencyInfo({this.econtact});

  factory EmergencyInfo.fromJson(Map<String, dynamic> json) {
    return EmergencyInfo(
      econtact: json['econtact']?.toString(),
    );
  }
}
