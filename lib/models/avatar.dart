class Avatar {
  final int id;
  final String url;
  final String name;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  Avatar(
      {required this.id,
      required this.url,
      required this.name,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['ID'],
      url: json['url'],
      name: json['name'],
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
      deletedAt: json['DeletedAt'],
    );
  }
}
