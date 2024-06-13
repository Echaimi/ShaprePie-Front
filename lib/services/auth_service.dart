import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String _baseUrl = 'http://localhost:8080/api/v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$_baseUrl/login';
    print('Login URL: $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    print('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData.containsKey('token')) {
        await _storage.write(key: 'auth_token', value: responseData['token']);
        return responseData;
      } else {
        throw Exception('Token not found in response');
      }
    } else {
      throw Exception('Failed to login: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final url = '$_baseUrl/signup';
    print('Register URL: $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Username': username,
        'email': email,
        'password': password,
      }),
    );

    print('Register response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Failed to register: ${responseData['message']}');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
