import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spaceshare/models/user.dart';
import 'package:spaceshare/services/user_service.dart';
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

  get token => null;

  Future<void> init() async {
    late String? firebaseToken;
    if (!kIsWeb) {
      firebaseToken = await FirebaseMessaging.instance.getToken();
      FirebaseMessaging.instance.onTokenRefresh.listen(_firebaseTokenHandler);
    }
    _isAuthenticated = await checkAuthentication();

    if (_isAuthenticated) {
      await loadCurrentUser();
    }

    await _firebaseTokenHandler(firebaseToken);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      await _storage.write(key: 'auth_token', value: response['token']);
      await loadCurrentUser();
      _isAuthenticated = true;
      final firebaseToken = await FirebaseMessaging.instance.getToken();
      _firebaseTokenHandler(firebaseToken);
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
    if (!_isAuthenticated || kIsWeb) {
      return;
    }
    if (token == null) {
      return;
    }
    await _userService.updateFirebaseToken(token);
  }
}
