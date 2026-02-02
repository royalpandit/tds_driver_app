class LocationModel {
  final String placeName;
  final String placeAddress;
  final double? latitude;
  final double? longitude;
  final String? eLoc;

  LocationModel({
    required this.placeName,
    required this.placeAddress,
    this.latitude,
    this.longitude,
    this.eLoc,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      placeName: map['placeName'] ?? '',
      placeAddress: map['placeAddress'] ?? '',
      latitude: _parseDouble(map['latitude']),
      longitude: _parseDouble(map['longitude']),
      eLoc: map['eLoc'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'placeName': placeName,
      'placeAddress': placeAddress,
      'latitude': latitude,
      'longitude': longitude,
      'eLoc': eLoc,
    };
  }

  @override
  String toString() => placeName;
}



