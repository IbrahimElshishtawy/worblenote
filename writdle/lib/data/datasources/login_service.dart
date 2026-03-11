// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email.trim());
  }

  static Future<bool> checkEmailExists(String email) async {
    if (!isValidEmail(email)) return false;

    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        email.trim(),
      );
      return methods.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Error message
    }
  }
}
