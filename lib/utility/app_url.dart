import 'dart:io';

class AppUrl {

  // static  String baseUrl = Platform.isAndroid? 'https://10.0.2.2:7169': 'https://localhost:7169';
  static  String baseUrl = Platform.isAndroid? 'http://localhost:7169': 'https://localhost:7169';

  static  String login = '$baseUrl/user/login';
  static  String register = '$baseUrl/user/register';
  static  String forgotPassword = '$baseUrl/forgot-password';
  static  String likePost = '$baseUrl/like';
}
