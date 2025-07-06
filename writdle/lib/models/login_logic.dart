import 'package:flutter/material.dart';
import 'package:writdle/service/login_service.dart';

class LoginLogic {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  BuildContext? context;
  bool isLoading = false;
  bool showPassword = false;
  String? errorMessage;
  bool? isEmailValid;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  void togglePasswordVisibility() {
    showPassword = !showPassword;
  }

  void onEmailChanged(String value) {
    if (value.contains('@')) {
      checkIfEmailExists(value.trim());
    }
  }

  Future<void> checkIfEmailExists(String email) async {
    isEmailValid = await LoginService.checkEmailExists(email);
    if (context != null) {
      (context as Element).markNeedsBuild(); // Trigger UI update
    }
  }

  Future<void> login() async {
    isLoading = true;
    errorMessage = null;
    if (context != null) (context as Element).markNeedsBuild();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final result = await LoginService.loginWithEmail(email, password);

    isLoading = false;
    if (result == null) {
      Navigator.pushReplacementNamed(context!, '/home');
    } else {
      errorMessage = result;
      (context as Element).markNeedsBuild();
    }
  }
}
