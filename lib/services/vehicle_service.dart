import '../models/vehicle_model.dart';
import 'api_client.dart';

class VehicleService {
  Future<List<Vehicle>> getVehicles() async {
    final response = await ApiClient.get('/vehicles');
    final List data = response['data'];
    return data.map((e) => Vehicle.fromJson(e)).toList();
  }
}