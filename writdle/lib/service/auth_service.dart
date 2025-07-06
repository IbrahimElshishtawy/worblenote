import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  /// نتيجة موحّدة: إما نجاح (null) أو كود خطأ ورسالة
  static Future<AuthResult?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    email = email.trim().toLowerCase();

    // 1) تحقُّق قوة كلمة المرور
    final passCheck = _validatePassword(password);
    if (passCheck != null) return passCheck;

    try {
      // 2) إنشاء الحساب
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 3) إرسال رسالة تفعيل
      await cred.user!.sendEmailVerification();

      // 4) كتابة بيانات Firestore داخل Batch
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid);

      batch.set(userDoc, {
        'name': name,
        'email': email,
        'uid': cred.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return null; // ✅ Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return AuthResult(
          code: 'email-already-in-use',
          message: 'هذا البريد مسجل بالفعل. حاول تسجيل الدخول.',
        );
      } else if (e.code == 'invalid-email') {
        return AuthResult(code: 'invalid-email', message: 'البريد غير صالح');
      } else if (e.code == 'weak-password') {
        return AuthResult(code: 'weak-password', message: 'كلمة المرور ضعيفة');
      } else {
        return AuthResult(code: e.code, message: e.message ?? 'خطأ غير معروف');
      }
    } catch (e) {
      return AuthResult(code: 'unexpected', message: 'حدث خطأ غير متوقع: $e');
    }
  }

  /// تحقُّق قوة كلمة المرور
  static AuthResult? _validatePassword(String pass) {
    if (pass.length < 8) {
      return AuthResult(
        code: 'short-password',
        message: 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
      );
    }
    return null;
  }
}

/// كلاس بسيط يجمع كود الخطأ والرسالة
class AuthResult {
  final String code;
  final String message;

  AuthResult({required this.code, required this.message});
}
