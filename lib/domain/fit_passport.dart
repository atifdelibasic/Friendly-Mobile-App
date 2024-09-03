
import 'package:friendly_mobile_app/domain/user.dart';

class FitPassport {
  int id;
  String dateCreated;
  bool isActive;
  String expireDate;
  User user;

  FitPassport({
    required this.id,
    required this.dateCreated,
    required this.isActive,
    required this.expireDate,
    required this.user
  });

  factory FitPassport.fromJson(Map<String, dynamic> json) {
    return FitPassport(
      id: json['id'] as int,
      dateCreated: json['dateCreated'] as String,
      isActive: json['isActive'] as bool,
      expireDate: json['expireDate'] as String,
      user: User.fromJson(json['user']),
    );
  }
}
