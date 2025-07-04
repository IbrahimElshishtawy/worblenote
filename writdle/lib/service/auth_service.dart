import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': name,
            'email': email,
            'uid': userCredential.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return null; // null معناها مفيش خطأ
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
