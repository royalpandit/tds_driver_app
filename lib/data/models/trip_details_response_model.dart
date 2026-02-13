class TripDetailsResponseModel {
  final RideRequestModel rideRequest;
  final CustomerModel customer;
  final CorporateModel? corporate;
  final TripModel trip;

  TripDetailsResponseModel({
    required this.rideRequest,
    required this.customer,
    this.corporate,
    required this.trip,
  });

  factory TripDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return TripDetailsResponseModel(
      rideRequest: RideRequestModel.fromJson(json['ride_request'] ?? {}),
      customer: CustomerModel.fromJson(json['customer'] ?? {}),
      corporate: json['corporate'] != null
          ? CorporateModel.fromJson(json['corporate'])
          : null,
      trip: TripModel.fromJson(json['trip'] ?? {}),
    );
  }
}
class RideRequestModel {
  final int id;
  final String requestType;
  final String tripCategory;
  final String pickupAddress;
  final String dropAddress;
  final String rideDate;
  final String rideTime;
  final String estimatedKm;
  final String estimatedMins;
  final String status;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;

  RideRequestModel({
    required this.id,
    required this.requestType,
    required this.tripCategory,
    required this.pickupAddress,
    required this.dropAddress,
    required this.rideDate,
    required this.rideTime,
    required this.estimatedKm,
    required this.estimatedMins,
    required this.status,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
  });

  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    return RideRequestModel(
      id: json['id'] ?? 0,
      requestType: json['request_type'] ?? '',
      tripCategory: json['trip_category'] ?? '',
      pickupAddress: json['pickup_address'] ?? '',
      dropAddress: json['drop_address'] ?? '',
      rideDate: json['ride_date'] ?? '',
      rideTime: json['ride_time'] ?? '',
      estimatedKm: json['estimated_km'] ?? '',
      estimatedMins: json['estimated_mins'] ?? '',
      status: json['status'] ?? '',
      pickupLat: json['pickup_lat'] != null ? double.tryParse(json['pickup_lat'].toString()) : null,
      pickupLng: json['pickup_lng'] != null ? double.tryParse(json['pickup_lng'].toString()) : null,
      dropLat: json['drop_lat'] != null ? double.tryParse(json['drop_lat'].toString()) : null,
      dropLng: json['drop_lng'] != null ? double.tryParse(json['drop_lng'].toString()) : null,
    );
  }
}
class CustomerModel {
  final int id;
  final String name;
  final String? email;

  CustomerModel({
    required this.id,
    required this.name,
    this.email,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
    );
  }
}
class CorporateModel {
  final int id;
  final String name;

  CorporateModel({
    required this.id,
    required this.name,
  });

  factory CorporateModel.fromJson(Map<String, dynamic> json) {
    return CorporateModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
class TripModel {
  final String status;
  final int id;
  final String tripDate;
  final String? tripStart;
  final String? tripEnd;
  final VehicleModel vehicle;
  final DriverModel driver;
  final List<PassengerModel> passengers;
  final List<TripLogModel> logs;

  TripModel({
    required this.status,
    required this.id,
    required this.tripDate,
    this.tripStart,
    this.tripEnd,
    required this.vehicle,
    required this.driver,
    required this.passengers,
    required this.logs,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      status: json['status'] ?? '',

      id: json['id'] ?? 0,
      tripDate: json['trip_date'] ?? '',
      tripStart: json['trip_start'],
      tripEnd: json['trip_end'],
      vehicle: VehicleModel.fromJson(json['vehicle'] ?? {}),
      driver: DriverModel.fromJson(json['driver'] ?? {}),
      passengers: (json['passengers'] as List<dynamic>?)
          ?.map((e) => PassengerModel.fromJson(e))
          .toList() ??
          [],
      logs: (json['logs'] as List<dynamic>?)
          ?.map((e) => TripLogModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}
class VehicleModel {
  final int id;
  final String model;

  VehicleModel({
    required this.id,
    required this.model,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      model: json['model'] ?? '',
    );
  }
}
class DriverModel {
  final int id;
  final String name;
  final String? phone;

  DriverModel({
    required this.id,
    required this.name,
    this.phone,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
    );
  }
}
class PassengerModel {
  final int id;
  final int tripEmployeeId;
  final String name;
  final String? phone;
  final String? image;
  final String userType;
  final String status;
  final String? otpVerifiedAt;

  PassengerModel({
    required this.id,
    required this.tripEmployeeId,
    required this.name,
    this.phone,
    this.image,
    required this.userType,
    required this.status,
    this.otpVerifiedAt,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      id: json['id'] ?? 0,
      tripEmployeeId: json['trip_employee_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      image: json['image'],
      userType: json['user_type'] ?? '',
      status: json['status'] ?? '',
      otpVerifiedAt: json['otp_verified_at'],
    );
  }
}
class TripLogModel {
  final int id;
  final String event;
  final String details;
  final DateTime loggedAt;

  TripLogModel({
    required this.id,
    required this.event,
    required this.details,
    required this.loggedAt,
  });

  factory TripLogModel.fromJson(Map<String, dynamic> json) {
    return TripLogModel(
      id: json['id'] ?? 0,
      event: json['event'] ?? '',
      details: json['details'] ?? '',
      loggedAt: DateTime.parse(json['logged_at']),
    );
  }
}
