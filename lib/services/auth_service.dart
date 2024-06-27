import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String _baseUrl = dotenv.env['API_URL']!;

  AuthService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$_baseUrl/login';

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

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final url = '$_baseUrl/signup';
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

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Failed to register: ${responseData['message']}');
    }
  }
}
