import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nsm/providers/user_provider.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;
  final UserProvider userProvider;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthProvider(this.authService, this.userProvider);

  Future<void> login(String email, String password) async {
    try {
      final response = await authService.login(email, password);
      await _storage.write(key: 'auth_token', value: response['token']);
      await userProvider.getCurrentUser();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final response = await authService.register(username, email, password);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    userProvider.user = null;
    notifyListeners();
  }

  Future<bool> isAuthenticated() async {
    String? token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}
