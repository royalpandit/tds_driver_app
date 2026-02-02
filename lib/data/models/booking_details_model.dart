import 'vehicle_model.dart';

class BookingDetails {
  final VehicleType vehicleType;
  final List<Inclusion> inclusions;
  final List<Exclusion> exclusions;
  final List<Extra> extras;
  final double estimatedFare;
  final String userType;
  final String pickupAddress;
  final String dropoffAddress;

  BookingDetails({
    required this.vehicleType,
    required this.inclusions,
    required this.exclusions,
    required this.extras,
    required this.estimatedFare,
    required this.userType,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      vehicleType: VehicleType.fromJson(json['vehicle_type'] ?? {}),
      inclusions: json['inclusions'] != null
          ? (json['inclusions'] as List)
              .map((e) => Inclusion.fromJson(e))
              .toList()
          : [],
      exclusions: json['exclusions'] != null
          ? (json['exclusions'] as List)
              .map((e) => Exclusion.fromJson(e))
              .toList()
          : [],
      extras: json['extras'] != null
          ? (json['extras'] as List).map((e) => Extra.fromJson(e)).toList()
          : [],
      estimatedFare: json['estimated_fare'] != null
          ? (json['estimated_fare'] is String 
              ? double.tryParse(json['estimated_fare']) ?? 0.0
              : (json['estimated_fare'] as num).toDouble())
          : 0.0,
      userType: json['user_type'] ?? '',
      pickupAddress: json['pickup_address'] ?? '',
      dropoffAddress: json['dropoff_address'] ?? '',
    );
  }
}

class Inclusion {
  final int id;
  final String name;
  final String? description;

  Inclusion({required this.id, required this.name, this.description});

  factory Inclusion.fromJson(Map<String, dynamic> json) {
    return Inclusion(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class Exclusion {
  final int id;
  final String name;
  final String? description;

  Exclusion({required this.id, required this.name, this.description});

  factory Exclusion.fromJson(Map<String, dynamic> json) {
    return Exclusion(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class Extra {
  final int id;
  final String name;
  final String? description;
  final double price;

  Extra({
    required this.id,
    required this.name,
    this.description,
    required this.price,
  });

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
    );
  }
}



