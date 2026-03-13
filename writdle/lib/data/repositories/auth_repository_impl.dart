import 'dart:async';

import 'package:writdle/core/auth/local_auth_store.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl() {
    _emitCurrentState();
  }

  final StreamController<bool> _authController =
      StreamController<bool>.broadcast();

  @override
  Future<String?> login(String email, String password) async {
    final account = await LocalAuthStore.findByEmail(email);
    if (account == null) {
      return 'No local account found for this email on this device.';
    }
    if (account.password != password.trim()) {
      return 'Incorrect password.';
    }

    await LocalAuthStore.setCurrentAccount(account);
    _authController.add(true);
    return null;
  }

  @override
  Future<void> logout() async {
    await LocalAuthStore.clearCurrentAccount();
    _authController.add(false);
  }

  @override
  Future<void> register(String name, String email, String password) async {
    await LocalAuthStore.registerAccount(
      name: name,
      email: email,
      password: password,
    );
    _authController.add(true);
  }

  @override
  Future<String?> currentUserId() => LocalAuthStore.getCurrentUserId();

  @override
  Future<bool> isAuthenticated() => LocalAuthStore.isAuthenticated();

  @override
  Stream<bool> get authStateChanges => _authController.stream;

  Future<void> _emitCurrentState() async {
    _authController.add(await LocalAuthStore.isAuthenticated());
  }
}
