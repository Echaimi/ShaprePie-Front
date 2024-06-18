import 'dart:convert';
import 'package:nsm/models/user.dart';
import 'package:nsm/services/api_service.dart';

class UserService {
  final ApiService apiService;

  UserService(this.apiService);

  Future<User> getCurrentUser() async {
    final response = await apiService.get('/users/me');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data['data']);
    }
    throw Exception('Failed to fetch user');
  }
}
