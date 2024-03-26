
class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String token;
  String? fullName;
  String profileImage;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.token,
    required this.profileImage,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> responseData) {
    String firstName = responseData['firstName'] ?? "";
    String lastName = responseData['lastName'] ?? "";

      String profileImageUrl = 'https://ui-avatars.com/api/?rounded=true&name=${"asdsad"}&size=300';
    if(responseData['profileImageUrl'] != null) {
      profileImageUrl = 'https://localhost:7169/images/' + responseData['profileImageUrl'] as String;
    }

    return User(
      id: responseData['id'] ?? 0,
      firstName: responseData['firstName'] ?? "",
      lastName: responseData['firstName'] ?? "",
      email: responseData['email'] ?? "" ,
      token: responseData['token'] ?? "" ,
      fullName: "$firstName $lastName",
      profileImage: profileImageUrl
    );
  }
}
