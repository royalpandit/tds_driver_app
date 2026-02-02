import '../../core/constants/api_constants.dart';

class VehicleType {
  final int id;
  final String name;
  final String displayName;
  final int seats;
  final int? bags;
  final String? description;
  final String image;
  final List<String> transferDetails;
  final bool status;
  final dynamic badges;

  VehicleType({
    required this.id,
    required this.name,
    required this.displayName,
    required this.seats,
    this.bags,
    this.description,
    required this.image,
    required this.transferDetails,
    required this.status,
    this.badges,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    String image = json['icon'] ?? json['image'] ?? '';
    if (image.startsWith('http://localhost') || image.startsWith('https://localhost')) {
      image = image.replaceFirst(RegExp(r'https?://localhost'), ApiConstants.baseUrl);
    }

    return VehicleType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? json['name'] ?? 'Unknown Vehicle',
      seats: json['seats'] ?? 4,
      bags: json['bags'],
      description: json['description'],
      image: image,
      transferDetails: json['transfer_details'] != null
          ? List<String>.from(json['transfer_details'])
          : [],
      status: json['status'] ?? true,
      badges: json['badges'],
    );
  }
}



