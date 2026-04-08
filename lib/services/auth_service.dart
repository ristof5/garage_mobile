import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';
import 'storage_service.dart';

class AuthService {
  // Ganti IP sesuai jaringan lokal kamu
  static const String baseUrl = 'http://10.67.133.165:8080';

  Future<LoginResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      // Simpan token otomatis
      await StorageService.saveToken(loginResponse.token);
      return loginResponse;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Login gagal');
    }
  }

  Future<void> logout() async {
    await StorageService.clearToken();
  }
}