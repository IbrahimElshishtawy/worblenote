import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('isLoggedIn', true);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isLoggedIn', false);
  }

  @override
  Future<void> register(String name, String email, String password) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'uid': cred.user!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isLoggedIn', true);
  }

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
