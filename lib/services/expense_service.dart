import 'dart:convert';
import 'package:nsm/services/websocket_service.dart';

import '../models/expense.dart';

class ExpenseService {
  final WebSocketService _webSocketService;

  ExpenseService(this._webSocketService);

  Stream<List<Expense>> get expensesStream {
    return _webSocketService.stream.where((data) {
      final json = jsonDecode(data);
      return json['type'] == 'expenses';
    }).map((data) {
      final List<dynamic> expensesJson = jsonDecode(data)['payload'];
      return expensesJson.map((json) => Expense.fromJson(json)).toList();
    });
  }

  void createExpense(Map<String, dynamic> data) {
    _webSocketService.send({'action': 'createExpense', 'payload': data});
  }

  void updateExpense(String expenseId, Map<String, dynamic> data) {
    _webSocketService.send({'action': 'updateExpense', 'payload': data});
  }

  void deleteExpense(String expenseId) {
    _webSocketService.send({'action': 'deleteExpense', 'payload': expenseId});
  }
}
