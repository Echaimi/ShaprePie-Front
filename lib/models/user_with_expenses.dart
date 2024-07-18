import 'package:spaceshare/models/avatar.dart';
import 'package:spaceshare/models/user.dart';

class UserWithExpenses extends User {
  final int expenseCount;
  final double totalExpenses;
  final double refundAmount;

  UserWithExpenses({
    required super.id,
    required super.email,
    required super.username,
    required super.role,
    required super.avatar,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    required this.expenseCount,
    required this.totalExpenses,
    required this.refundAmount,
  });

  factory UserWithExpenses.fromJson(Map<String, dynamic> json) {
    return UserWithExpenses(
      id: json['ID'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      avatar: Avatar.fromJson(json['avatar']),
      createdAt:
          json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      updatedAt:
          json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
      deletedAt:
          json['DeletedAt'] != null ? DateTime.parse(json['DeletedAt']) : null,
      expenseCount: json['expense_count'] as int,
      totalExpenses: (json['total_expenses'] as num).toDouble(),
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  get user => null;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['expense_count'] = expenseCount;
    json['total_expenses'] = totalExpenses;
    json['refund_amount'] = refundAmount;
    return json;
  }
}
