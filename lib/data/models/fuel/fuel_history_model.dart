class FuelHistoryResponse {
  final List<FuelHistory> data;
  final Pagination pagination;

  FuelHistoryResponse({
    required this.data,
    required this.pagination,
  });

  factory FuelHistoryResponse.fromJson(Map<String, dynamic> json) {
    return FuelHistoryResponse(
      data: (json['data'] as List)
          .map((e) => FuelHistory.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class FuelHistory {
  final int id;
  final DateTime date;
  final double qty;
  final double costPerUnit;
  final double totalCost;
  final double startMeter;
  final double endMeter;
  final double consumption;
  final String fuelFrom;
  final bool complete;
  final FuelVehicle vehicle;

  FuelHistory({
    required this.id,
    required this.date,
    required this.qty,
    required this.costPerUnit,
    required this.totalCost,
    required this.startMeter,
    required this.endMeter,
    required this.consumption,
    required this.fuelFrom,
    required this.complete,
    required this.vehicle,
  });

  factory FuelHistory.fromJson(Map<String, dynamic> json) {
    return FuelHistory(
      id: json['id'],
      date: DateTime.parse(json['date']),
      qty: double.parse(json['qty'].toString()),
      costPerUnit: double.parse(json['cost_per_unit'].toString()),
      totalCost: double.parse(json['total_cost'].toString()),
      startMeter: double.parse(json['start_meter'].toString()),
      endMeter: double.parse(json['end_meter'].toString()),
      consumption: double.parse(json['consumption'].toString()),
      fuelFrom: json['fuel_from'],
      complete: json['complete'],
      vehicle: FuelVehicle.fromJson(json['vehicle']),
    );
  }

  // 👉 formatted date for UI
  String get formattedDate {
    return "${date.day.toString().padLeft(2,'0')}-"
        "${date.month.toString().padLeft(2,'0')}-"
        "${date.year}";
  }
}

class FuelVehicle {
  final int id;
  final String name;
  final String number;

  FuelVehicle({
    required this.id,
    required this.name,
    required this.number,
  });

  factory FuelVehicle.fromJson(Map<String, dynamic> json) {
    return FuelVehicle(
      id: json['id'],
      name: json['name'],
      number: json['number'],
    );
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final bool hasMore;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      perPage: json['per_page'],
      total: json['total'],
      lastPage: json['last_page'],
      hasMore: json['has_more'],
    );
  }
}
