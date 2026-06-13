import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<void> requestOtp(String phoneNumber, UserRole role);
  Future<void> requestOtpSms(String phoneNumber);
  Future<AuthSession> verifyOtp(String phoneNumber, String code);
  Future<AuthSession> loginCleaner({
    required String phoneNumber,
    required String password,
  });
  Future<void> completeProfile({
    required String name,
    required String email,
    required String address,
  });
  Future<AuthSession?> restoreSession();
  Future<void> saveSession(AuthSession session);
  Future<void> clearSession();
}
