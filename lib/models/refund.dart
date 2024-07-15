import 'package:spaceshare/models/event.dart';
import 'package:spaceshare/models/user.dart';

class Refund {
  final int id;
  final int fromUserId;
  final User from;
  final int toUserId;
  final User to;
  final double amount;
  final int eventId;
  final Event event;
  final int authorId;
  final User author;
  final DateTime date;

  Refund({
    required this.id,
    required this.fromUserId,
    required this.from,
    required this.toUserId,
    required this.to,
    required this.amount,
    required this.eventId,
    required this.event,
    required this.authorId,
    required this.author,
    required this.date,
  });

  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'],
      fromUserId: json['fromUserId'],
      from: User.fromJson(json['from']),
      toUserId: json['toUserId'],
      to: User.fromJson(json['to']),
      amount: json['amount'],
      eventId: json['eventId'],
      event: Event.fromJson(json['event']),
      authorId: json['authorId'],
      author: User.fromJson(json['author']),
      date: DateTime.parse(json['date']),
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
      'eventId': eventId,
      'event': event.toJson(),
      'authorId': authorId,
      'author': author.toJson(),
      'date': date.toIso8601String(),
    };
  }
}
