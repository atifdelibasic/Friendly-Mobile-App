import '../utility/app_url.dart';
import 'hobby.dart';

class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String token;
  String? fullName;
  String profileImage;
  String description;
  List<Hobby>? hobbies;
  String? birthDate;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.token,
    required this.profileImage,
    required this.description,
    this.birthDate,
    this.hobbies,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> responseData) {
    String firstName = responseData['firstName'] ?? "";
    String lastName = responseData['lastName'] ?? "";

    String profileImageUrl =
        'https://ui-avatars.com/api/?rounded=true&name=ad&size=300';
    if (responseData['profileImageUrl'] != null &&
        responseData['profileImageUrl'] != "") {
      profileImageUrl =
          '${AppUrl.baseUrl}/images/' + responseData['profileImageUrl'];
    }

    List<Hobby>? hobbiesList;
    if (responseData['hobbies'] != null) {
      hobbiesList = (responseData['hobbies'] as List)
          .map((hobbyJson) => Hobby.fromJson(hobbyJson))
          .toList();
    }

    return User(
      id: responseData['id'] ?? 0,
      firstName: responseData['firstName'] ?? "",
      lastName: responseData['lastName'] ?? "",
      email: responseData['email'] ?? "",
      token: responseData['token'] ?? "",
      fullName: "$firstName $lastName",
      profileImage: profileImageUrl,
      description: responseData['description'] ?? "",
      hobbies: hobbiesList,
      birthDate: responseData["birthDate"],
    );
  }
}
