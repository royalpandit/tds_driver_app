class FuelType {
  final int id;
  final String label;
  final String unit;

  FuelType({
    required this.id,
    required this.label,
    required this.unit,
  });

  factory FuelType.fromJson(Map<String, dynamic> json) {
    return FuelType(
      id: json['id'],
      label: json['label'],
      unit: json['unit'],
    );
  }
}
