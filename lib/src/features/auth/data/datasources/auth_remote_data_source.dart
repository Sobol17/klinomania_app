import '../../domain/entities/auth_session.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource();

  String _lastRole = 'client';

  Future<void> requestOtp(String phoneNumber, String role) async {
    _lastRole = role;
    await _mockDelay();
  }

  Future<void> requestOtpSms(String phoneNumber) async {
    await _mockDelay();
  }

  Future<AuthSessionModel> verifyOtp(String phoneNumber, String code) async {
    await _mockDelay();
    return AuthSessionModel(
      accessToken: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
      tokenType: 'Bearer',
      phoneNumber: phoneNumber,
      isNewUser: true,
      role: UserRoleSerializer.fromJson(_lastRole),
    );
  }

  Future<AuthSessionModel> loginCleaner({
    required String phoneNumber,
    required String password,
  }) async {
    await _mockDelay();
    if (password.isEmpty) {
      throw StateError('Введите пароль');
    }

    return AuthSessionModel(
      accessToken:
          'mock-cleaner-token-${DateTime.now().millisecondsSinceEpoch}',
      tokenType: 'Bearer',
      phoneNumber: phoneNumber,
      isNewUser: false,
      role: UserRole.cleaner,
    );
  }

  Future<void> _mockDelay() {
    return Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
