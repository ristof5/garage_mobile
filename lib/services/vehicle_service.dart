import '../models/vehicle_model.dart';
import 'api_client.dart';

class VehicleService {
  Future<List<Vehicle>> getVehicles() async {
    final response = await ApiClient.get('/vehicles');
    final List data = response['data'];
    return data.map((e) => Vehicle.fromJson(e)).toList();
  }

  Future<void> createVehicle(String brand, String model, int year) async {
    await ApiClient.post('/vehicles', {
      'brand': brand,
      'model': model,
      'year': year,
    });
  }

  Future<void> updateVehicle(int id, String brand, String model, int year) async {
    await ApiClient.put('/vehicles/$id', {
      'brand': brand,
      'model': model,
      'year': year,
    });
  }

  Future<void> deleteVehicle(int id) async {
    await ApiClient.delete('/vehicles/$id');
  }
}