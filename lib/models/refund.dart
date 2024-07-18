import 'user.dart';

class Refund {
  final int id;
  final int? fromUserId;
  final User from;
  final int? toUserId;
  final User to;
  final double amount;
  final DateTime date;

  Refund({
    required this.id,
    this.fromUserId,
    required this.from,
    this.toUserId,
    required this.to,
    required this.amount,
    required this.date,
  });

  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['ID'],
      fromUserId: json['fromUserId'],
      from: User.fromJson(json['from']),
      toUserId: json['toUserId'],
      to: User.fromJson(json['to']),
      amount: (json['amount']).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'from': from.toJson(),
      'toUserId': toUserId,
      'to': to.toJson(),
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
