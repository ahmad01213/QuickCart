abstract class AuthRepository {
  Future<bool> loginWithEmail(String email, String password);
  Future<bool> loginWithPhone(String phone, String countryCode);
  Future<bool> verifyOtp(String code);
  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<void> saveSession();
}
