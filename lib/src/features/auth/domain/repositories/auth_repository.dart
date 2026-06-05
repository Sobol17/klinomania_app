import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<void> requestOtp(String phoneNumber, UserRole role);
  Future<void> requestOtpSms(String phoneNumber);
  Future<AuthSession> verifyOtp(String phoneNumber, String code);
  Future<void> completeProfile({
    required String name,
    required String email,
    required String address,
    required String district,
  });
  Future<AuthSession?> restoreSession();
  Future<void> saveSession(AuthSession session);
  Future<void> clearSession();
}
