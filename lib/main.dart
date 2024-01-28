import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/interceptors.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/feed.dart';
import 'dart:io';
import 'package:friendly_mobile_app/providers/auth_provider.dart';
import 'package:friendly_mobile_app/providers/user_provider.dart';
import 'domain/user.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

void main() {
   MyApi.setupInterceptors();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<User> getUserData() => UserPreferences().getUser();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

  
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: FutureBuilder(
              future: getUserData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.data?.token == "") {
                      return Login();
                    } else {
                      Provider.of<UserProvider>(context).setUser(snapshot.data);
                    }

                    return Feed();
                }
              }),
          routes: {
            '/login': (context) => Login(),
            '/register': (context) => Register(),
            '/feed': (context) => Feed(),
          },
        ));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
