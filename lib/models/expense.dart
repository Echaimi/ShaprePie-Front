import 'package:nsm/models/participant.dart';
import 'package:nsm/models/payer.dart';
import 'package:nsm/models/tag.dart';
import 'package:nsm/models/user.dart';

class Expense {
  final int id;
  final String title;
  final double amount;
  final DateTime createdAt;
  final String description;
  final User author;
  final String image;
  final Tag tag;
  final int eventId;
  final List<Participant> participants;
  final List<Payer> payers;

  Expense(
      {required this.id,
      required this.title,
      required this.amount,
      required this.description,
      required this.createdAt,
      required this.author,
      required this.image,
      required this.tag,
      required this.eventId,
      required this.participants,
      required this.payers});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['ID'],
      title: json['title'],
      amount: json['amount'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      author: User.fromJson(json['author']),
      image: json['image'],
      tag: Tag.fromJson(json['tag']),
      eventId: json['event_id'],
      participants: (json['participants'] as List)
          .map((participant) => Participant.fromJson(participant))
          .toList(),
      payers: (json['payers'] as List)
          .map((payer) => Payer.fromJson(payer))
          .toList(),
    );
  }
}
