import 'package:flutter/material.dart';
import 'package:nsm/services/user_service.dart';
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
}
