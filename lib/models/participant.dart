import 'user.dart';

class Participant {
  final int? id;
  final User user;
  final double amount;

  Participant({this.id, required this.user, required this.amount});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      user: User.fromJson(json['user']),
      amount: json['amount'].toDouble(),
    );
  }
}
