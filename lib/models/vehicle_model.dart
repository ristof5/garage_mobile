class Vehicle {
  final int id;
  final String brand;
  final String model;
  final int year;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
    );
  }

  // Nama lengkap untuk ditampilkan di UI
  String get fullName => '$brand $model $year';
}