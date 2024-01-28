import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MyApi {
  static final Dio dio = Dio();

  static void setupInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // You can add any headers or configurations here

        return handler.next(options); // continue with the request
      },
      onResponse: (response, handler) {
        // Handle the response if needed
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        // Handle the error
        if (e.response?.statusCode == 401) {
          // Redirect to the login page
          // You can use Navigator to navigate to your login page
          // For example:
          // Navigator.of(context).pushReplacementNamed('/login');
        }

        return handler.next(e);
      },
    ));
  }
}
