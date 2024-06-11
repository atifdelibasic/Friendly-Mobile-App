
import 'package:friendly_mobile_app/domain/user.dart';

class Notification {
  int id;
  String message;
  User recipient;
  User sender;
  DateTime dateCreated;

  Notification({
    required this.id,
    required this.message,
    required this.recipient,
    required this.sender,
    required this.dateCreated,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      message: json['message'] as String,
      recipient:  User.fromJson(json['recipient']) ,
      sender: User.fromJson(json['sender']),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }
}
