import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/providers/auth_provider.dart';
import 'package:friendly_mobile_app/providers/user_provider.dart';
import 'domain/user.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/feed.dart';
import 'dart:io';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:provider/provider.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<User> getUserData() => UserPreferences().getUser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

            if (snapshot.data?.token == "") {
              print("idi na login");
              return Login();
            } else {
              print("idi ovdje breee");
              print(snapshot.data?.token);
              print(snapshot.data);

              // If setUser is asynchronous, you should use Future.microtask
              Future.microtask(() {
                userProvider.setUser(snapshot.data);
              });

              return Feed();
            }
          }
        },
      ),
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/feed': (context) => Feed(),
      },
    );
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
