class FuelPrice {
  final String price;
  final String unit;
  final String label;

  FuelPrice({
    required this.price,
    required this.unit,
    required this.label,
  });

  factory FuelPrice.fromJson(Map<String, dynamic> json) {
    return FuelPrice(
      price: json['price'],
      unit: json['unit'],
      label: json['label'],
    );
  }
}
