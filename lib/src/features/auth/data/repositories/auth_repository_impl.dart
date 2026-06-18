import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<void> requestOtp(String phoneNumber, UserRole role) {
    return remoteDataSource.requestOtp(
      phoneNumber,
      UserRoleSerializer.toJson(role),
    );
  }

  @override
  Future<void> requestOtpSms(String phoneNumber) {
    return remoteDataSource.requestOtpSms(phoneNumber);
  }

  @override
  Future<AuthSession> verifyOtp(String phoneNumber, String code) async {
    final session = await remoteDataSource.verifyOtp(phoneNumber, code);
    return session.toEntity();
  }

  @override
  Future<AuthSession> loginCleaner({
    required String phoneNumber,
    required String password,
  }) async {
    final session = await remoteDataSource.loginCleaner(
      phoneNumber: phoneNumber,
      password: password,
    );
    return session.toEntity();
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final session = await localDataSource.loadSession();
    return session?.toEntity();
  }

  @override
  Future<void> saveSession(AuthSession session) {
    final model = AuthSessionModel.fromEntity(session);
    return localDataSource.saveSession(model);
  }

  @override
  Future<void> clearSession() {
    return localDataSource.clearSession();
  }
}
