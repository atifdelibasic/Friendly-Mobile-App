import 'package:friendly_mobile_app/domain/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("token " + user.token);
    prefs.setString('firstName', user.firstName);
    prefs.setString('lastName', user.lastName);
    prefs.setString('email', user.email);
    prefs.setString('token', user.token);
    prefs.setInt('id', user.id);
    prefs.setString('profileImageUrl', user.profileImage);
    prefs.setString('birthDate', user.birthDate ?? "");

    return await prefs.setBool('loggedIn', true);
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt("id") ?? 0;
    String firstName = prefs.getString("firstName") ?? "";
    String email = prefs.getString("email") ?? "";
    String lastName = prefs.getString("lastName") ?? "";
    String token = prefs.getString("token") ?? "";
    String profileImageUrl = prefs.getString("profileImageUrl") ?? "";
    String birthDate = prefs.getString("birthDate") ?? "";

    return User(
        id: id,
        firstName: firstName,
        email: email,
        lastName: lastName,
        token: token,
        profileImage: profileImageUrl,
        description: "",
        birthDate: birthDate
       );
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove('id');
    prefs.remove('lastName');
    prefs.remove('email');
    prefs.remove('firstName');
    prefs.remove('token');
    prefs.remove('profileImageUrl');
    prefs.remove('birthDate');

  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    return token;
  }
}
