import 'package:nsm/models/user.dart';

class Transaction {
  final int id;
  final User from;
  final User to;
  final double amount;
  final int eventId;
  final bool completed;

  Transaction({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.eventId,
    required this.completed,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      from: User.fromJson(json['from']),
      to: User.fromJson(json['to']),
      amount: json['amount'].toDouble(),
      eventId: json['eventId'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from.toJson(),
      'to': to.toJson(),
      'amount': amount,
      'eventId': eventId,
      'completed': completed,
    };
  }
}
