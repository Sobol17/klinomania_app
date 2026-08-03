import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/core/network/api_client.dart';
import 'package:klinomania/src/features/auth/domain/entities/auth_session.dart';
import 'package:klinomania/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:klinomania/src/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  const session = AuthSession(
    accessToken: '1|plain-text-token',
    tokenType: 'Bearer',
    phoneNumber: '+79990000001',
    isNewUser: false,
    role: UserRole.client,
  );

  test('sets Bearer token before notifying about successful login', () async {
    final adapter = _RecordingAdapter();
    final apiClient = _client(adapter);
    final controller = AuthController(
      repository: _AuthRepository(verifiedSession: session),
      apiClient: apiClient,
    );
    await controller.restoreSession();
    controller.start(UserRole.client);
    await controller.submitPhone(session.phoneNumber);

    Future<void>? firstAuthenticatedRequest;
    controller.addListener(() {
      if (controller.isAuthenticated && firstAuthenticatedRequest == null) {
        firstAuthenticatedRequest = apiClient.get<void>(
          '/api/v1/client/services',
        );
      }
    });

    await controller.submitCode('1111');
    await firstAuthenticatedRequest;

    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer 1|plain-text-token',
    );
  });

  test('sets Bearer token before restoring an authenticated session', () async {
    final adapter = _RecordingAdapter();
    final apiClient = _client(adapter);
    final controller = AuthController(
      repository: _AuthRepository(restoredSession: session),
      apiClient: apiClient,
    );

    Future<void>? firstAuthenticatedRequest;
    controller.addListener(() {
      if (controller.isAuthenticated && firstAuthenticatedRequest == null) {
        firstAuthenticatedRequest = apiClient.get<void>(
          '/api/v1/client/services',
        );
      }
    });

    await controller.restoreSession();
    await firstAuthenticatedRequest;

    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer 1|plain-text-token',
    );
  });
}

ApiClient _client(_RecordingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = adapter;
  return ApiClient(dio: dio);
}

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

class _AuthRepository implements AuthRepository {
  _AuthRepository({this.verifiedSession, this.restoredSession});

  final AuthSession? verifiedSession;
  final AuthSession? restoredSession;

  @override
  Future<void> clearSession() async {}

  @override
  Future<AuthSession> loginCleaner({
    required String phoneNumber,
    required String code,
  }) async {
    return verifiedSession!;
  }

  @override
  Future<void> requestOtp(String phoneNumber, UserRole role) async {}

  @override
  Future<void> requestOtpSms(String phoneNumber) async {}

  @override
  Future<AuthSession?> restoreSession() async => restoredSession;

  @override
  Future<void> saveSession(AuthSession session) async {}

  @override
  Future<AuthSession> verifyOtp(String phoneNumber, String code) async {
    return verifiedSession!;
  }
}
