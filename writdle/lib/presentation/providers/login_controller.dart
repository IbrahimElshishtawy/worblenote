import 'package:flutter/material.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';

class LoginController with ChangeNotifier {
  final IAuthRepository _repository;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

  LoginController(this._repository);

  bool get isLoading => _isLoading;
  bool get showPassword => _showPassword;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  Future<bool> login(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please fill in all fields';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final result = await _repository.login(email, password);

    if (result == null) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
