import 'dart:convert';

class JwtHelper {
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Payload ada di bagian ke-2 (index 1)
      String payload = parts[1];

      // Tambah padding base64 kalau kurang
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded);
    } catch (_) {
      return null;
    }
  }

  static String? getRole(String token) {
    return decode(token)?['role'] as String?;
  }

  static int? getUserId(String token) {
    final id = decode(token)?['user_id'];
    if (id == null) return null;
    return (id as num).toInt();
  }
}