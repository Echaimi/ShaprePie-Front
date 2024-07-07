import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nsm/models/user.dart';
import 'package:nsm/services/user_service.dart';
import '../services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late User? _user;
  bool _isAuthenticated = false;

  AuthProvider(this._authService, this._userService) {
    init();
  }

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> init() async {
    final firebaseToken = await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.instance.onTokenRefresh.listen(_firebaseTokenHandler);
    _isAuthenticated = await checkAuthentication();
    if (_isAuthenticated) {
      print('Is Authenticated: $_isAuthenticated');
      await loadCurrentUser();
      await _firebaseTokenHandler(firebaseToken);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      await _storage.write(key: 'auth_token', value: response['token']);
      await loadCurrentUser();
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      final response = await _authService.register(username, email, password);
      notifyListeners();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> checkAuthentication() async {
    String? token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<void> loadCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      _user = user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _firebaseTokenHandler(String? token) async {
    print('Firebase Token: $token');
    if (!_isAuthenticated) {
      return;
    }
    if (token == null) {
      return;
    }
    await _userService.updateFirebaseToken(token);
  }
}
