class ServiceModel {
  final int id;
  final int vehicleId;
  final String description;
  final int cost;
  final String serviceDate;

  ServiceModel({
    required this.id,
    required this.vehicleId,
    required this.description,
    required this.cost,
    required this.serviceDate,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      description: json['description'],
      cost: json['cost'],
      serviceDate: json['service_date'],
    );
  }

  // Format rupiah untuk ditampilkan di UI
  String get formattedCost {
    final str = cost.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}