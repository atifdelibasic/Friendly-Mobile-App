import 'package:flutter/material.dart';

InputDecoration buildInputDecoration(String hintText, IconData? icon) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
    hintText: hintText,
    labelText: hintText,
    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
    prefixIcon: Icon(icon, size:22),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(12),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  );
}
