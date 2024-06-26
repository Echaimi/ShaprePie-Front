import 'dart:convert';
import 'package:nsm/models/avatar.dart';
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

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await apiService.patch('/users/me', data);

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> updatedData = json.decode(response.body);
        // Si la réponse est enveloppée dans une clé "data", accédez-y correctement.
        var userData = updatedData['data'] ?? updatedData;
        return User.fromJson(userData);
      } catch (e) {
        print('Erreur lors du décodage de la réponse: $e');
        rethrow;
      }
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  Future<List<Avatar>> getAvatars() async {
    final response = await apiService.get('/avatars');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((e) => Avatar.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load avatars');
    }
  }


}
