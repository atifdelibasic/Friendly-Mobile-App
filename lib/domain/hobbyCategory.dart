class HobbyCategory {
  int id;
  String name;

  HobbyCategory({
    required this.id,
    required this.name,
  });

  factory HobbyCategory.fromJson(Map<String, dynamic> json) {
    return HobbyCategory(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
