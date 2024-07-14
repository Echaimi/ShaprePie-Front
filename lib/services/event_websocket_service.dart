import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spaceshare/models/balance.dart';
import 'package:spaceshare/models/transaction.dart';
import 'package:spaceshare/models/user_with_expenses.dart';
import 'package:spaceshare/providers/auth_provider.dart';
import '../models/event.dart';
import '../models/expense.dart';
import '../services/websocket_service.dart';

class EventWebsocketProvider with ChangeNotifier {
  final WebSocketService _webSocketService;
  final AuthProvider _authProvider;
  Event? _event;
  List<UserWithExpenses> _users = [];
  List<Expense> _expenses = [];
  List<Balance> _balances = [];
  List<Transaction> _transactions = [];

  EventWebsocketProvider(this._webSocketService, this._authProvider) {
    _listenToWebSocket();
  }

  Event? get event => _event;

  List<UserWithExpenses> get users => _users;

  List<Expense> get expenses => _expenses;

  List<Balance> get balances => _balances;

  List<Transaction> get transactions => _transactions;

  double get totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double get userTotalExpenses {
    final userId = _authProvider.user?.id;
    return _expenses
        .where(
            (expense) => expense.payers.any((payer) => payer.user.id == userId))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double get userAmountOwed {
    final userId = _authProvider.user?.id;

    if (userId == null || _balances.isEmpty) return 0.00;

    return _balances.firstWhere((balance) => balance.user.id == userId).amount;
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
        case 'balances':
          final balances =
              (payload as List).map((b) => Balance.fromJson(b)).toList();
          _balances = balances;
          notifyListeners();
          break;
        case 'transactions':
          final transactions =
              (payload as List).map((t) => Transaction.fromJson(t)).toList();
          _transactions = transactions;
          notifyListeners();
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

  void updateEvent(Map<String, dynamic> data) {
    _webSocketService.send({'type': 'updateEvent', 'payload': data});
  }

  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}
