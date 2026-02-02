class RideBookingRequest {
  final String tripCategory;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double dropLat;
  final double dropLng;
  final String dropAddress;
  final String rideDate;
  final String rideTime;
  final int vehicleTypeId;
  final int seatsRequired;
  final String? package;
  final int? customHours;
  final int? customKm;
  final String? pickupEloc;
  final String? dropEloc;
  final double? estimatedDistanceKm;
  final int? estimatedDurationMins;
  final int? routeId;
  final String? routeName;

  RideBookingRequest({
    required this.tripCategory,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.dropLat,
    required this.dropLng,
    required this.dropAddress,
    required this.rideDate,
    required this.rideTime,
    required this.vehicleTypeId,
    required this.seatsRequired,
    this.package,
    this.customHours,
    this.customKm,
    this.pickupEloc,
    this.dropEloc,
    this.estimatedDistanceKm,
    this.estimatedDurationMins,
    this.routeId,
    this.routeName,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'trip_category': tripCategory,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'pickup_address': pickupAddress,
      'drop_lat': dropLat,
      'drop_lng': dropLng,
      'drop_address': dropAddress,
      'ride_date': rideDate,
      'ride_time': rideTime,
      'vehicle_type_id': vehicleTypeId,
      'seats_required': seatsRequired,
    };

    if (package != null) json['package'] = package;
    if (customHours != null) json['custom_hours'] = customHours;
    if (customKm != null) json['custom_km'] = customKm;
    if (pickupEloc != null) json['pickup_eloc'] = pickupEloc;
    if (dropEloc != null) json['drop_eloc'] = dropEloc;
    if (estimatedDistanceKm != null) json['estimated_distance_km'] = estimatedDistanceKm;
    if (estimatedDurationMins != null) json['estimated_duration_mins'] = estimatedDurationMins;
    if (routeId != null) json['route_id'] = routeId;
    if (routeName != null) json['routeName'] = routeName;

    return json;
  }
}

class RideBookingResponse {
  final bool status;
  final String message;
  final int? code;
  final RideBookingData? data;

  RideBookingResponse({
    required this.status,
    required this.message,
    this.code,
    this.data,
  });

  factory RideBookingResponse.fromJson(Map<String, dynamic> json) {
    return RideBookingResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      code: json['code'],
      data: json['data'] != null ? RideBookingData.fromJson(json['data']) : null,
    );
  }
}

class RideBookingData {
  final int bookingId;
  final String requestType;
  final String status;
  final String approvalStatus;
  final int priority;
  final String rideDate;
  final String rideTime;
  final String pickupAddress;
  final String dropAddress;
  final int vehicleTypeId;
  final int seatsRequired;

  RideBookingData({
    required this.bookingId,
    required this.requestType,
    required this.status,
    required this.approvalStatus,
    required this.priority,
    required this.rideDate,
    required this.rideTime,
    required this.pickupAddress,
    required this.dropAddress,
    required this.vehicleTypeId,
    required this.seatsRequired,
  });

  factory RideBookingData.fromJson(Map<String, dynamic> json) {
    return RideBookingData(
      bookingId: json['booking_id'] ?? 0,
      requestType: json['request_type'] ?? '',
      status: json['status'] ?? '',
      approvalStatus: json['approval_status'] ?? '',
      priority: json['priority'] ?? 0,
      rideDate: json['ride_date'] ?? '',
      rideTime: json['ride_time'] ?? '',
      pickupAddress: json['pickup_address'] ?? '',
      dropAddress: json['drop_address'] ?? '',
      vehicleTypeId: json['vehicle_type_id'] ?? 0,
      seatsRequired: json['seats_required'] ?? 1,
    );
  }
}



