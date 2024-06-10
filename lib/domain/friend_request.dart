import 'package:friendly_mobile_app/domain/user.dart';

class FriendRequest {
  int id;
  User user;
  int? friendId;
  int status;

  FriendRequest({
    required this.id,
    required this.user,
    this.friendId,
    required this.status,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      user: User.fromJson(json['user']),
      friendId: json['friend'] != null ? json['friend']['id'] : null,
      status: json['status'],
    );
  }
}
