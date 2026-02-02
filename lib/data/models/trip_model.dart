class RideRequestOffer {
  final int offerId;
  final int rideRequestId;
  final String status;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final RideRequest rideRequest;

  RideRequestOffer({
    required this.offerId,
    required this.rideRequestId,
    required this.status,
    this.respondedAt,
    required this.createdAt,
    required this.rideRequest,
  });

  factory RideRequestOffer.fromJson(Map<String, dynamic> json) {
    return RideRequestOffer(
      offerId: json['id'] ?? 0,
      rideRequestId: json['ride_request_id'] ?? 0,
      status: json['status'] is String ? json['status'] : json['status']?.toString() ?? '',
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      rideRequest: json['ride_request'] is Map<String, dynamic> ? RideRequest.fromJson(json['ride_request']) : RideRequest.fromJson({}),
    );
  }
}

class RideRequest {
  final int id;
  final String requestType;
  final String tripCategory;
  final String pickupAddress;
  final String dropAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String rideDate;
  final String rideTime;
  final double estimatedDistance;
  final int estimatedDuration;
  final String vehicleType;
  final int? seatsRequired;
  final dynamic package;
  final String status;
  final dynamic approvalStatus;
  final String? routeName;
  final Customer? customer;
  final Corporate? corporate;

  RideRequest({
    required this.id,
    required this.requestType,
    required this.tripCategory,
    required this.pickupAddress,
    required this.dropAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.rideDate,
    required this.rideTime,
    required this.estimatedDistance,
    required this.estimatedDuration,
    required this.vehicleType,
    this.seatsRequired,
    this.package,
    required this.status,
    this.approvalStatus,
    this.routeName,
    this.customer,
    this.corporate,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'] ?? 0,
      requestType: json['request_type'] is String ? json['request_type'] : json['request_type']?.toString() ?? '',
      tripCategory: json['trip_category'] is String ? json['trip_category'] : json['trip_category']?.toString() ?? '',
      pickupAddress: json['pickup_address'] is String ? json['pickup_address'] : json['pickup_address']?.toString() ?? '',
      dropAddress: json['drop_address'] is String ? json['drop_address'] : json['drop_address']?.toString() ?? '',
      pickupLat: double.tryParse(json['pickup_lat'].toString()) ?? 0.0,
      pickupLng: double.tryParse(json['pickup_lng'].toString()) ?? 0.0,
      dropLat: double.tryParse(json['drop_lat'].toString()) ?? 0.0,
      dropLng: double.tryParse(json['drop_lng'].toString()) ?? 0.0,
      rideDate: json['ride_date'] is String ? json['ride_date'] : json['ride_date']?.toString() ?? '',
      rideTime: json['ride_time'] is String ? json['ride_time'] : json['ride_time']?.toString() ?? '',
      estimatedDistance: double.tryParse(json['estimated_distance_km'].toString()) ?? 0.0,
      estimatedDuration: json['estimated_duration_mins'] != null ? int.tryParse(json['estimated_duration_mins'].toString()) ?? 0 : 0,
      vehicleType: json['vehicle_type'] != null && json['vehicle_type'] is Map<String, dynamic>
          ? json['vehicle_type']['displayname'] ?? json['vehicle_type']['vehicletype'] ?? ''
          : json['vehicle_type_id']?.toString() ?? '',
      seatsRequired: json['seats_required'] != null ? int.tryParse(json['seats_required'].toString()) : null,
      package: json['package'],
      status: json['status'] is String ? json['status'] : json['status']?.toString() ?? '',
      approvalStatus: json['approval_status'],
      routeName: json['route_name'] is String ? json['route_name'] : json['route_name']?.toString(),
      customer: json['customer'] != null && json['customer'] is Map ? Customer.fromJson(json['customer']) : null,
      corporate: json['corporate'] != null && json['corporate'] is Map ? Corporate.fromJson(json['corporate']) : null,
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String? email;

  Customer({
    required this.id,
    required this.name,
    this.email,
  });

  factory Customer.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return Customer(
        id: json['id'] ?? 0,
        name: json['name'] is String ? json['name'] : json['name']?.toString() ?? '',
        email: json['email'] is String ? json['email'] : json['email']?.toString(),
      );
    }
    return Customer(id: 0, name: '');
  }
}

class Corporate {
  final int id;
  final String name;

  Corporate({
    required this.id,
    required this.name,
  });

  factory Corporate.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return Corporate(
        id: json['id'] ?? 0,
        name: json['name'] is String ? json['name'] : json['name']?.toString() ?? '',
      );
    }
    return Corporate(id: 0, name: '');
  }
}

class Trip {
  final int id;
  final String tripDate;
  final String tripType;
  final String status;
  final TripRoutes routes;
  final Vehicle vehicle;
  final DriverSummary driver;
  final int employeesCount;

  Trip({
    required this.id,
    required this.tripDate,
    required this.tripType,
    required this.status,
    required this.routes,
    required this.vehicle,
    required this.driver,
    required this.employeesCount,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? 0,
      tripDate: json['trip_date'] ?? '',
      tripType: json['trip_type'] ?? '',
      status: json['status'] ?? '',
      routes: TripRoutes.fromJson(json['routes'] ?? {}),
      vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
      driver: DriverSummary.fromJson(json['driver'] ?? {}),
      employeesCount: json['employees_count'] ?? 0,
    );
  }
}

class TripRoutes {
  final RouteInfo? morning;
  final RouteInfo? evening;

  TripRoutes({
    this.morning,
    this.evening,
  });

  factory TripRoutes.fromJson(Map<String, dynamic> json) {
    return TripRoutes(
      morning: json['morning'] != null ? RouteInfo.fromJson(json['morning']) : null,
      evening: json['evening'] != null ? RouteInfo.fromJson(json['evening']) : null,
    );
  }
}

class RouteInfo {
  final int id;
  final String name;

  RouteInfo({
    required this.id,
    required this.name,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Vehicle {
  final int id;
  final String numberPlate;
  final String model;

  Vehicle({
    required this.id,
    required this.numberPlate,
    required this.model,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? 0,
      numberPlate: json['number_plate'] ?? '',
      model: json['model'] ?? '',
    );
  }
}

class DriverSummary {
  final int id;
  final String name;
  final String? email;

  DriverSummary({
    required this.id,
    required this.name,
    this.email,
  });

  factory DriverSummary.fromJson(Map<String, dynamic> json) {
    return DriverSummary(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['Email'],
    );
  }
}

class TripDetails {
  final RideRequest rideRequest;
  final List<Customer> customers;
  final Corporate? corporate;
  final TripInfo trip;
  final List<TripLog> logs;

  TripDetails({
    required this.rideRequest,
    required this.customers,
    this.corporate,
    required this.trip,
    required this.logs,
  });

  factory TripDetails.fromJson(Map<String, dynamic> json) {
    return TripDetails(
      rideRequest: RideRequest.fromJson(json['ride_request'] ?? {}),
      customers: (json['customers'] as List<dynamic>?)
          ?.map((customer) => Customer.fromJson(customer))
          .toList() ?? [Customer.fromJson(json['customer'] ?? {})],
      corporate: json['corporate'] != null ? Corporate.fromJson(json['corporate']) : null,
      trip: TripInfo.fromJson(json['trip'] ?? {}),
      logs: (json['logs'] as List<dynamic>?)
          ?.map((log) => TripLog.fromJson(log))
          .toList() ?? [],
    );
  }
}

class TripInfo {
  final int id;
  final String tripDate;
  final Vehicle vehicle;
  final DriverWithPhone driver;
  final List<TripLog> logs;

  TripInfo({
    required this.id,
    required this.tripDate,
    required this.vehicle,
    required this.driver,
    required this.logs,
  });

  factory TripInfo.fromJson(Map<String, dynamic> json) {
    return TripInfo(
      id: json['id'] ?? 0,
      tripDate: json['trip_date'] ?? '',
      vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
      driver: DriverWithPhone.fromJson(json['driver'] ?? {}),
      logs: (json['logs'] as List<dynamic>?)
          ?.map((log) => TripLog.fromJson(log))
          .toList() ?? [],
    );
  }
}

class DriverWithPhone extends DriverSummary {
  final String phone;

  DriverWithPhone({
    required super.id,
    required super.name,
    super.email,
    required this.phone,
  });

  factory DriverWithPhone.fromJson(Map<String, dynamic> json) {
    return DriverWithPhone(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['Email'],
      phone: json['phone'] ?? '',
    );
  }
}

class TripLog {
  final int id;
  final String event;
  final String details;
  final DateTime loggedAt;

  TripLog({
    required this.id,
    required this.event,
    required this.details,
    required this.loggedAt,
  });

  factory TripLog.fromJson(Map<String, dynamic> json) {
    return TripLog(
      id: json['id'] ?? 0,
      event: json['event'] ?? '',
      details: json['details'] ?? '',
      loggedAt: DateTime.parse(json['logged_at'] ?? ''),
    );
  }
}

class Expense {
  final int id;
  final String vehicleMaker;
  final String vehicleModel;
  final String licensePlate;
  final String expenseType;
  final String? vendor;
  final String date;
  final double amount;
  final String? note;
  final String category; // 'income' or 'expense'

  Expense({
    required this.id,
    required this.vehicleMaker,
    required this.vehicleModel,
    required this.licensePlate,
    required this.expenseType,
    this.vendor,
    required this.date,
    required this.amount,
    this.note,
    required this.category,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      vehicleMaker: json['vehicle_maker'] ?? '',
      vehicleModel: json['vehicle_model'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      expenseType: json['expense_type'] ?? json['income_type'] ?? '',
      vendor: json['vendor'],
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      note: json['note'],
      category: json['category'] ?? 'expense',
    );
  }
}



