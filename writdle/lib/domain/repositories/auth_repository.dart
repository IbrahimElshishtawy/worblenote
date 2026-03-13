abstract class IAuthRepository {
  Future<String?> login(String email, String password);
  Future<void> logout();
  Future<void> register(String name, String email, String password);
  Future<String?> currentUserId();
  Future<bool> isAuthenticated();
  Stream<bool> get authStateChanges;
}
