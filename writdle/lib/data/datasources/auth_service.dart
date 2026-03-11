import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static Future<AuthResult?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    email = email.trim().toLowerCase();

    final passCheck = _validatePassword(password);
    if (passCheck != null) return passCheck;

    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await cred.user!.sendEmailVerification();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': name,
        'email': email,
        'uid': cred.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        code: e.code,
        message: _mapFirebaseError(e.code),
      );
    } catch (e) {
      return AuthResult(code: 'unexpected', message: 'An unexpected error occurred: $e');
    }
  }

  static String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static AuthResult? _validatePassword(String pass) {
    if (pass.length < 8) {
      return AuthResult(
        code: 'short-password',
        message: 'Password must be at least 8 characters long.',
      );
    }
    return null;
  }
}

class AuthResult {
  final String code;
  final String message;

  AuthResult({required this.code, required this.message});
}
