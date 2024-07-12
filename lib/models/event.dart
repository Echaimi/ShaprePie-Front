import 'user.dart';
import 'category.dart';

class Event {
  final int id;
  final String name;
  final String description;
  final User author;
  final Category category;
  final String image;
  final double goal;
  final String code;
  late final String state;
  final int? userCount;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.category,
    required this.image,
    required this.goal,
    required this.code,
    required this.state,
    required this.userCount,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['ID'],
      name: json['name'],
      description: json['description'],
      author: User.fromJson(json['author']),
      category: Category.fromJson(json['category']),
      image: json['image'],
      goal: json['goal'].toDouble(),
      code: json['code'],
      state: json['state'],
      userCount: json['userCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'name': name,
      'description': description,
      'author': author.toJson(),
      'category': category.toJson(),
      'image': image,
      'goal': goal,
      'code': code,
      'state': state,
      'userCount': userCount,
    };
  }
}
