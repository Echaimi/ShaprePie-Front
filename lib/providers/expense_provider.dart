import 'package:flutter/material.dart';
import 'package:nsm/services/expense_service.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService expenseService;

  List<Expense> _expenses = [];

  ExpenseProvider({required this.expenseService}) {
    _listen();
  }

  List<Expense> get expenses => _expenses;

  void _listen() {
    expenseService.expensesStream.listen((expenses) {
      _expenses = expenses;
      notifyListeners();
    });
  }

  void addExpense(Map<String, dynamic> data) {
    expenseService.createExpense(data);
  }

  void updateExpense(String expenseId, Map<String, dynamic> data) {
    expenseService.updateExpense(expenseId, data);
  }

  void deleteExpense(String expenseId) {
    expenseService.deleteExpense(expenseId);
  }
}
