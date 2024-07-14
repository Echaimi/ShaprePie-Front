import 'dart:convert';
import 'package:spaceshare/models/avatar.dart';
import 'package:spaceshare/models/user.dart';
import 'package:spaceshare/services/api_service.dart';

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
        var userData = updatedData['data'] ?? updatedData;
        return User.fromJson(userData);
      } catch (e) {
        throw Exception('Failed to update user: $e');
      }
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  Future<User> updateFirebaseToken(String token) async {
    final response = await apiService
        .patch('/users/firebase_token', {'firebaseToken': token});

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data['data']);
    } else {
      throw Exception('Failed to update firebase token');
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

  Future<List<User>> getUsers() async {
    final response = await apiService.get('/users');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List users = data['data'];
      return users.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<User> getUser(int userId) async {
    final response = await apiService.get('/users/$userId');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      final user = data['data'];
      return User.fromJson(user);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    final response = await apiService.post('/users', data);

    if (response.statusCode == 201) {
      Map<String, dynamic> createdData = json.decode(response.body);
      return User.fromJson(createdData);
    } else {
      throw Exception('Failed to create user');
    }
  }

  Future<User> updateUser(int userId, Map<String, dynamic> data) async {
    final response = await apiService.patch('/users/$userId', data);

    if (response.statusCode == 200) {
      Map<String, dynamic> updatedData = json.decode(response.body);
      return User.fromJson(updatedData);
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await apiService.delete('/users/$userId');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }
}
