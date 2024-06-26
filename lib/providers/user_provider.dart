import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/domain/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User? user) {
    print("set user se poziva " + user!.profileImage);
    _user = user;
    notifyListeners();
  }
}
