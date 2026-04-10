import 'storage_service.dart';
import '../helpers/jwt_helpers.dart';

class AuthProvider {
  static String? _token;
  static String? _role;
  static int? _userId;

  static Future<void> load() async {
    _token = await StorageService.getToken();
    if (_token != null) {
      _role = JwtHelper.getRole(_token!);
      _userId = JwtHelper.getUserId(_token!);
    }
  }

  static String? get token => _token;
  static String? get role => _role;
  static int? get userId => _userId;
  static bool get isAdmin => _role == 'admin';
  static bool get isLoggedIn => _token != null;

  static void clear() {
    _token = null;
    _role = null;
    _userId = null;
  }
}
