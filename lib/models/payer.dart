import 'user.dart';

class Payer {
  final int id;
  final User user;
  final double amount;

  Payer({required this.id, required this.user, required this.amount});

  factory Payer.fromJson(Map<String, dynamic> json) {
    return Payer(
      id: json['id'],
      user: User.fromJson(json['user']),
      amount: json['amount'].toDouble(),
    );
  }
}
