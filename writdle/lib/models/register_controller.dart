// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:writdle/service/auth_service.dart';

class RegisterController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool isPasswordMatched = true;

  bool showPassword = false;
  bool showConfirmPassword = false;

  void togglePasswordVisibility() {
    showPassword = !showPassword;
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword = !showConfirmPassword;
  }

  void checkPasswordMatch() {
    isPasswordMatched =
        confirmPasswordController.text.trim() == passwordController.text.trim();
  }

  Future<void> registerUser(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    checkPasswordMatch();

    if (!isPasswordMatched) {
      errorMessage = "Passwords do not match";
      isLoading = false;
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final result = await AuthService.registerUser(
      name: name,
      email: email,
      password: password,
    );

    if (result == null) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      errorMessage = result;
    }

    isLoading = false;
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
