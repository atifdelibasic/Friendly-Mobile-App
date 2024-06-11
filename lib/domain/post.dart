import 'package:friendly_mobile_app/domain/user.dart';

import '../utility/app_url.dart';

class Post {
  final int id;
  final String profileImage;
  final String username;
  final String postImage;
  final String description;
  int likes;
  final int comments;
  bool isLikedByUser;
  final String dateCreated;
  final String hobbyName;
  final int userId;
  final User user;

  Post({
    required this.id,
    required this.profileImage,
    required this.username,
    required this.postImage,
    required this.description,
    required this.likes,
    required this.comments,
    required this.isLikedByUser,
    required this.dateCreated,
    required this.hobbyName,
    required this.userId,
    required this.user
  });

  factory Post.fromJson(Map<String, dynamic> responseData) {
    final user = User.fromJson(responseData['user']);

    String profileImageUrl = 'https://ui-avatars.com/api/?rounded=true&name=${user.fullName}&size=300';
    if(responseData['user']['profileImageUrl'] != null && responseData['user']['profileImageUrl'] != "") {
      profileImageUrl = '${AppUrl.baseUrl}/images/' + responseData['user']['profileImageUrl'];
    }

    String postImage = "";
    if(responseData['imagePath'] != null) {
     postImage = "${AppUrl.baseUrl}/images/" + responseData['imagePath'];
    }

    return Post(
      id: responseData['id'] ?? 0,
      profileImage: profileImageUrl,
      username: user.fullName ?? '',
      postImage: postImage,
      description: responseData['description'] ?? '',
      likes: responseData['likeCount'] ?? 0,
      comments: responseData['commentCount'] ?? 0,
      isLikedByUser: responseData['isLikedByUser'] ?? false,
      dateCreated: responseData['dateCreated'],
      hobbyName: responseData['hobby']['title'],
      userId: responseData['user']['id'],
      user: user,
    );
  }
}

