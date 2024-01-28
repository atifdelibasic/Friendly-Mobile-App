class Comment {
  final int id;
  final String text;
  final String dateCreated;
  final String fullName; // Combined first and last names
  final String profileImageUrl;

  Comment({
    required this.id,
    required this.text,
    required this.dateCreated,
    required this.fullName,
    required this.profileImageUrl
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
     final firstName = user['firstName'] as String;
    final lastName = user['lastName'] as String;
    final fullName = '$firstName $lastName';

    final profileImageUrl = user['profileImageUrl'] as String? ?? 'https://ui-avatars.com/api/?rounded=true&name=$firstName+$lastName';

    return Comment(
      id: json['id'] as int,
      text: json['text'] as String,
      dateCreated: json['dateCreated'] as String,
      fullName: fullName,
      profileImageUrl: profileImageUrl,
    );
  }
}