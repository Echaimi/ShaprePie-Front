import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spaceshare/models/websocket_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spaceshare/models/balance.dart';
import 'package:spaceshare/models/transaction.dart';
import 'package:spaceshare/models/user_with_expenses.dart';
import 'package:spaceshare/providers/auth_provider.dart';
import '../models/event.dart';
import '../models/expense.dart';
import '../models/refund.dart';

class EventWebsocketProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  final AuthProvider _authProvider;
  Event? _event;
  List<UserWithExpenses> _users = [];
  List<Expense> _expenses = [];
  List<Balance> _balances = [];
  List<Transaction> _transactions = [];
  List<Refund> _refunds = [];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  EventWebsocketProvider(int eventId, this._authProvider) {
    _initialize(eventId);
  }

  Event? get event => _event;
  List<UserWithExpenses> get users => _users;
  List<Expense> get expenses => _expenses;
  List<Balance> get balances => _balances;
  List<Transaction> get transactions => _transactions;
  List<Refund> get refunds => _refunds;

  double get totalExpenses =>
      _expenses.fold(0, (sum, expense) => sum + expense.amount);

  double get userTotalExpenses {
    final userId = _authProvider.user?.id;
    return _expenses
        .where(
            (expense) => expense.payers.any((payer) => payer.user.id == userId))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double? get userAmountOwed {
    final userId = _authProvider.user?.id;

    if (userId == null || _balances.isEmpty) return 0.00;

    return _balances.firstWhere((balance) => balance.user.id == userId).amount;
  }

  Expense? getExpenseById(int id) {
    try {
      return _expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  Balance? get userBalance {
    final userId = _authProvider.user?.id;
    if (userId == null || _balances.isEmpty) return null;

    return _balances.firstWhere((balance) => balance.user.id == userId);
  }

  Refund? getRefundById(int id) {
    try {
      return _refunds.firstWhere((refund) => refund.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _initialize(int eventId) async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token not found');
      }
      final wsUrl =
          '${dotenv.env['API_WS_URL']}/ws/events/$eventId?authorization=Bearer $token';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel?.stream.listen(_handleMessage);
    } catch (e) {}
  }

  void _handleMessage(message) {
    final data = jsonDecode(message);
    final webSocketMessage = WebSocketMessage.fromJson(data);

    switch (webSocketMessage.type) {
      case 'event':
        final event = Event.fromJson(webSocketMessage.payload);
        _updateEvent(event);
        break;
      case 'expenses':
        final expenses = (webSocketMessage.payload as List)
            .map((e) => Expense.fromJson(e))
            .toList();
        _updateExpenses(expenses);
        break;
      case 'refunds':
        try {
          final refunds = (webSocketMessage.payload as List)
              .map((r) => Refund.fromJson(r))
              .toList();
          _updateRefunds(refunds);
        } catch (e, stackTrace) {}
        break;
      case 'users':
        final users = (webSocketMessage.payload as List)
            .map((u) => UserWithExpenses.fromJson(u))
            .toList();
        _updateUsers(users);
        break;
      case 'balances':
        final balances = (webSocketMessage.payload as List)
            .map((b) => Balance.fromJson(b))
            .toList();
        _balances = balances;
        notifyListeners();
        break;
      case 'transactions':
        final transactions = (webSocketMessage.payload as List)
            .map((t) => Transaction.fromJson(t))
            .toList();
        _transactions = transactions;
        notifyListeners();
        break;
    }
  }

  void createRefundFromTransaction(Transaction transaction) {
    final dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    final formattedDate = dateFormat.format(DateTime.now());

    final data = {
      'amount': transaction.amount,
      'fromUserId': transaction.from.id,
      'toUserId': transaction.to.id,
      'date': formattedDate,
    };
    createRefund(data);
  }

  void createRefund(Map<String, dynamic> data) {
    _sendMessage(WebSocketMessage(type: 'createRefund', payload: data));
    notifyListeners();
  }

  void updateRefund(int refundId, Map<String, dynamic> data) {
    data["id"] = refundId;
    _sendMessage(WebSocketMessage(type: 'updateRefund', payload: data));
    notifyListeners();
  }

  void _updateEvent(Event event) {
    _event = event;
    notifyListeners();
  }

  void _updateExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }

  void _updateRefunds(List<Refund> refunds) {
    _refunds = refunds;
    notifyListeners();
  }

  void deleteRefund(int refundId) {
    final data = {'id': refundId};
    _sendMessage(WebSocketMessage(type: 'deleteRefund', payload: data));
    notifyListeners();
  }

  void _updateUsers(List<UserWithExpenses> users) {
    _users = users;
    notifyListeners();
  }

  void createExpense(Map<String, dynamic> data) {
    _sendMessage(WebSocketMessage(type: 'createExpense', payload: data));
    notifyListeners();
  }

  void updateExpense(int expenseId, Map<String, dynamic> data) {
    data["id"] = expenseId;
    _sendMessage(WebSocketMessage(type: 'updateExpense', payload: data));
    notifyListeners();
  }

  void deleteExpense(int expenseId) {
    final data = {'id': expenseId};
    _sendMessage(WebSocketMessage(type: 'deleteExpense', payload: data));
    notifyListeners();
  }

  void updateEvent(Map<String, dynamic> data) {
    _sendMessage(WebSocketMessage(type: 'updateEvent', payload: data));
  }

  void _sendMessage(WebSocketMessage message) {
    try {
      _channel?.sink.add(message.toString());
    } catch (e) {}
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
