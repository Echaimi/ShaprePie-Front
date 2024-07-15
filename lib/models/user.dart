import 'package:spaceshare/models/avatar.dart';

class User {
  final int id;
  final String email;
  final String username;
  final String role;
  final Avatar avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.avatar,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'email': email,
      'username': username,
      'role': role,
      'avatar': avatar,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
      'DeletedAt': deletedAt?.toIso8601String(),
    };
  }
}
