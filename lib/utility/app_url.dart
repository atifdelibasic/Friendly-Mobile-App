import 'dart:io';

class AppUrl {

  static  String baseUrl = Platform.isAndroid? 'http://10.0.2.2:7169': 'http://localhost:7169';

  static  String login = '$baseUrl/user/login';
  static  String register = '$baseUrl/user/register';
  static  String forgotPassword = '$baseUrl/forgot-password';
  static  String likePost = '$baseUrl/like';
}
