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
  final String state;

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
    );
  }
}
