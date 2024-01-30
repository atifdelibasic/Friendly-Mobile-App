class User {
  int id;
  String name;
  String email;
  String phone;
  String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.token,
  });

  // now create converter
  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
      id: responseData['id'] ?? 0,
      name: responseData['Username'] ?? "",
      email: responseData['email'] ?? "" ,
      phone: responseData['phone'] ?? "",
      token: responseData['message'] ?? "",
    );
  }
}
