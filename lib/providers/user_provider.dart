import 'package:flutter/material.dart';
import 'package:nsm/services/user_service.dart';
import '../models/avatar.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final UserService userService;
  User? _user;

  UserProvider(this.userService);

  User? get user => _user;

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<User> getCurrentUser() async {
    try {
      final user = await userService.getCurrentUser();
      _user = user;
      notifyListeners();
      return user;
    } catch (e) {
      rethrow;
    }
  }


  Future<void> updateUserProfile(updatedData) async {
    try {
      if (_user == null || _user!.id == null) {
        throw Exception('User or user ID is null, cannot update profile.');
      }

      final updatedUser = await userService.updateProfile(updatedData);

      _user = updatedUser;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }



  Future<List<Avatar>> getAvatars() async {
    return await userService.getAvatars();
  }

}