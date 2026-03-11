import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final IAuthRepository _repository;
  User? _user;

  AuthProvider(this._repository) {
    _repository.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> logout() async {
    await _repository.logout();
  }
}
