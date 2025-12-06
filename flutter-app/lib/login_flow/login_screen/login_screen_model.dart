import 'package:flutter/material.dart';

class LoginScreenModel {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  void toggleObscure() {
    obscurePassword = !obscurePassword;
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
