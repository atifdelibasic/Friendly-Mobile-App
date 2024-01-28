class Hobby {
  int id;
  String title;

  Hobby({
    required this.id,
    required this.title,
  });

  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}
