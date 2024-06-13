import 'package:flutter/material.dart';
import 'package:nsm/services/user_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;
  final UserService userService;
  bool _isAuthenticated = false;
  User? _user;

  AuthProvider(this.authService, this.userService);

  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;

  Future<void> login(String email, String password) async {
    try {
      final response = await authService.login(email, password);
      if (response.containsKey('token')) {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final response = await authService.register(username, email, password);
      final userData = response['data'] as Map<String, dynamic>;
      _user = User.fromJson(userData);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
