// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:writdle/service/auth_service.dart';

class RegisterController with ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordMatched = true;

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordMatched => _isPasswordMatched;
  bool get showPassword => _showPassword;
  bool get showConfirmPassword => _showConfirmPassword;

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _showConfirmPassword = !_showConfirmPassword;
    notifyListeners();
  }

  void checkPasswordMatch() {
    _isPasswordMatched =
        confirmPasswordController.text.trim() == passwordController.text.trim();
  }

  Future<void> registerUser(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    checkPasswordMatch();

    if (!_isPasswordMatched) {
      _errorMessage = "Passwords do not match";
      _isLoading = false;
      notifyListeners();
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
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
