// auth_service.dart
import 'package:get_storage/get_storage.dart';

class AuthService {
  static final _storage = GetStorage();

  static Future<void> logout() async {
    await _storage.remove('TOKEN');
    await _storage.remove('USER');
    // Ajoutez ici d'autres clés à nettoyer si nécessaire
  }

  static bool isLoggedIn() {
    return _storage.hasData('TOKEN');
  }
}