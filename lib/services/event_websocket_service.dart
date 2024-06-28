import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:nsm/models/user_with_expenses.dart';
import '../models/event.dart';
import '../models/expense.dart';
import '../services/websocket_service.dart';

class EventWebsocketProvider with ChangeNotifier {
  final WebSocketService _webSocketService;

  Event? _event;
  List<UserWithExpenses> _users = [];
  List<Expense> _expenses = [];

  Event? get event => _event;

  List<UserWithExpenses> get users => _users;

  List<Expense> get expenses => _expenses;

  double get totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // double get userTotalExpenses {
  //   final userId = _userProvider.user?.id;
  //   print(userId);
  //   print(_expenses.where(
  //       (expense) => expense.payers.any((payer) => payer.user.id == userId)));
  //   return _expenses
  //       .where(
  //           (expense) => expense.payers.any((payer) => payer.user.id == userId))
  //       .fold(0, (sum, expense) => sum + expense.amount);
  // }

  EventWebsocketProvider(this._webSocketService) {
    _listenToWebSocket();
  }

  void _listenToWebSocket() {
    _webSocketService.stream?.listen((message) {
      final data = jsonDecode(message);
      final type = data['type'];
      final payload = data['payload'];

      switch (type) {
        case 'event':
          final event = Event.fromJson(payload);
          _updateEvent(event);
          break;
        case 'expenses':
          final expenses =
              (payload as List).map((e) => Expense.fromJson(e)).toList();
          _updateExpenses(expenses);
          break;
        case 'users':
          final users = (payload as List)
              .map((u) => UserWithExpenses.fromJson(u))
              .toList();
          _updateUsers(users);
          break;
      }
    });
  }

  void _updateEvent(Event event) {
    _event = event;
    notifyListeners();
  }

  void _updateExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }

  void _updateUsers(List<UserWithExpenses> users) {
    _users = users;
    notifyListeners();
  }

  void createExpense(Map<String, dynamic> data) {
    _webSocketService.send({'type': 'createExpense', 'payload': data});
  }

  void updateExpense(String expenseId, Map<String, dynamic> data) {
    _webSocketService.send({'type': 'updateExpense', 'payload': data});
  }

  void deleteExpense(String expenseId) {
    _webSocketService.send({'type': 'deleteExpense', 'payload': expenseId});
  }

  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}
