class Like {
  final int id;
  final int postId;
  final String fullName; // Combined first and last names
  final String profileImageUrl;

  Like({
    required this.id,
    required this.postId,
    required this.fullName,
    required this.profileImageUrl
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final firstName = user['firstName'] as String;
    final lastName = user['lastName'] as String;
    final fullName = '$firstName $lastName';
    print("ovdje sam");
    print(user['profileImageUrl']);

    final profileImageUrl = user['profileImageUrl']  ?? 'https://ui-avatars.com/api/?rounded=true&name=$firstName+$lastName';
    final modifiedProfileImageUrl = profileImageUrl == null ? 'https://localhost:7169/$profileImageUrl' : profileImageUrl;
    return Like(
      id:json['id'] as int,
      postId: json['postId'] as int,
      fullName: fullName,
      profileImageUrl: modifiedProfileImageUrl,
    );
  }
}