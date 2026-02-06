class FuelStation {
  final int id;
  final String name;
  final String? address;

  FuelStation({
    required this.id,
    required this.name,
    this.address,
  });

  factory FuelStation.fromJson(Map<String, dynamic> json) {
    return FuelStation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}
