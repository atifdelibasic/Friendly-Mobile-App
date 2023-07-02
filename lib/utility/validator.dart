import 'package:friendly_mobile_app/utility/validation_messages.dart';

String? validateEmail(String? value) {
  if (value?.isEmpty ?? true) {
    return ValidationMessages.emailRequired;
  }

  final emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$',
    caseSensitive: false,
  );

  if (!emailRegex.hasMatch(value!)) {
    return ValidationMessages.invalidEmail;
  }

  return null;
}

String? validateName(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return 'Please enter your $fieldName.';
  }
  
  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
    return 'Please enter a valid $fieldName with letters only.';
  }

   if (value.length < 2) {
    return '$fieldName must be at least 2 characters long.';
  }

  return null;
}