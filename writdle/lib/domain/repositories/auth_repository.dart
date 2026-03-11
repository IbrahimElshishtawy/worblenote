import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthRepository {
  Future<String?> login(String email, String password);
  Future<void> logout();
  Future<void> register(String name, String email, String password);
  User? get currentUser;
  Stream<User?> get authStateChanges;
}
