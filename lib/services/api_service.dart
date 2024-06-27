import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _baseUrl = dotenv.env['API_URL']!;
  final _storage = const FlutterSecureStorage();

  ApiService();

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<http.Response> get(String endpoint) async {
    final url = '$_baseUrl$endpoint';
    final token = await getToken();

    return http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = '$_baseUrl$endpoint';
    final token = await getToken();

    return http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  Future<http.Response> patch(
      String endpoint, Map<String, dynamic> data) async {
    final url = '$_baseUrl$endpoint';
    final token = await getToken();

    return http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final url = '$_baseUrl$endpoint';
    final token = await getToken();

    return http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
