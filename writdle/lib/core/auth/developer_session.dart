import 'package:shared_preferences/shared_preferences.dart';

class DeveloperSession {
  static const String developerEmail = 'shishtawy@gmail.com';
  static const String developerPassword = 'hima123';
  static const String developerUserId = 'developer_local';
  static const String developerName = 'Developer Account';
  static const String developerBio =
      'Local developer mode is active for testing the app without Firebase auth.';

  static const _sessionKey = 'developer_session_enabled';

  static bool matchesCredentials(String email, String password) {
    return email.trim().toLowerCase() == developerEmail &&
        password.trim() == developerPassword;
  }

  static Future<void> enable() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_sessionKey, true);
    await preferences.setBool('isLoggedIn', true);
  }

  static Future<void> disable() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_sessionKey, false);
  }

  static Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_sessionKey) ?? false;
  }
}
