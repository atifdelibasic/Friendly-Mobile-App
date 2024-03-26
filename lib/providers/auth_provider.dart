import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/domain/user.dart';
import 'package:friendly_mobile_app/utility/app_url.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:http/http.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider extends ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;

  set loggedInStatus(Status value) {
    _loggedInStatus = value;
  }

  Status get registeredInStatus => _registeredInStatus;

  set registeredInStatus(Status value) {
    _registeredInStatus = value;
  }

  Future<Map<String, dynamic>> register(String? email, String? password, String? firstName, String? lastName) async {
    final Map<String, dynamic> apiBodyData = {
  "firstName": firstName,
  "lastName": lastName,
  "email": email,
  "password": password
    };

    try {
      final response = await post(Uri.parse(AppUrl.register),
          body: json.encode(apiBodyData),
          headers: {'Content-Type': 'application/json'});
      print("response");

      final responseBody = json.decode(response.body);
      print(responseBody);
      return responseBody;
      
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  notify() {
    notifyListeners();
  }

  static Future<FutureOr> onValue(Response response) async {
    var result;

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      var userData = responseData['data'];

      // now we will create a user model
      User authUser = User.fromJson(responseData);

      // now we will create shared preferences and save data
      UserPreferences().saveUser(authUser);

      result = {
        'status': true,
        'message': 'Successfully registered',
        'data': authUser
      };
    } else {
      result = {
        'status': false,
        'message': 'Successfully registered',
        'data': responseData
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> login(String? email, String? password) async {
    var result;
    final Map<String, dynamic> loginData = {
      'email': email,
      'password':password
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();
    print(AppUrl.login);

    Response response = await post(
      Uri.parse(AppUrl.login),
      body: json.encode(loginData),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response");
    print(response.statusCode);

    if (response.statusCode == 200) {
      print("evo ga dvi joje");
      final Map<String, dynamic> responseData = json.decode(response.body);
      print("response data");
      print(responseData);
      User authUser = User.fromJson(responseData['user']);
      authUser.token = responseData['message'];
      print("auth user");
      print(authUser);
      UserPreferences().saveUser(authUser);

      _loggedInStatus = Status.LoggedIn;
      print("notify listeners");
      notifyListeners();

      print(json.decode(response.body));

      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);

      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': responseData['message']
      };
    }

    return result;
  }

  static onError(error) {
    print('the error is ${error.detail}');
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }
}
