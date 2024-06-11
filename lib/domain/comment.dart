import 'package:friendly_mobile_app/utility/app_url.dart';

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

  String profileImageUrl = user['profileImageUrl'] ?? "";
    if(profileImageUrl == "") {
     profileImageUrl = 'https://ui-avatars.com/api/?rounded=true&name=$firstName+$lastName';
    } else {
      profileImageUrl = "${AppUrl.baseUrl}/images/" + profileImageUrl;
    }
    return Comment(
      id: json['id'] as int,
      text: json['text'] as String,
      dateCreated: json['dateCreated'] as String,
      fullName: fullName,
      profileImageUrl: profileImageUrl,
    );
  }
}