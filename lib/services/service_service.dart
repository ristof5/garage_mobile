import '../models/service_model.dart';
import 'api_client.dart';

class ServiceService {
  Future<List<ServiceModel>> getServices() async {
    final response = await ApiClient.get('/services');
    final List data = response['data'];
    return data.map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<List<ServiceModel>> getServicesByVehicle(int vehicleId) async {
    final response = await ApiClient.get('/vehicles/$vehicleId/services');
    final List data = response['data'];
    return data.map((e) => ServiceModel.fromJson(e)).toList();
  }
}