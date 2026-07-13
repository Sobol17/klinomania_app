import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/core/network/api_client.dart';
import 'package:klinomania/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:klinomania/src/features/auth/domain/entities/auth_session.dart';

void main() {
  group('AuthRemoteDataSource', () {
    test('requests client OTP code', () async {
      final adapter = _FakeAdapter(responseJson: {'message': 'Code sent.'});
      final dataSource = _dataSource(adapter);

      await dataSource.requestOtp('+79990000001', 'client');

      expect(adapter.lastOptions?.path, '/api/v1/client/auth/request-code');
      expect(adapter.lastOptions?.data, {'phone': '+79990000001'});
    });

    test('verifies client OTP code', () async {
      final adapter = _FakeAdapter(
        responseJson: {
          'token': '1|plain-text-token',
          'user': {'phone': '+79990000001', 'role': 'client'},
        },
      );
      final dataSource = _dataSource(adapter);

      final session = await dataSource.verifyOtp('+79990000001', '1111');

      expect(adapter.lastOptions?.path, '/api/v1/client/auth/verify-code');
      expect(adapter.lastOptions?.data, {
        'phone': '+79990000001',
        'code': '1111',
      });
      expect(session.accessToken, '1|plain-text-token');
      expect(session.role, UserRole.client);
    });

    test('logs cleaner in with 6 digit code', () async {
      final adapter = _FakeAdapter(
        responseJson: {
          'token': '2|plain-text-token',
          'user': {'phone': '+79990000003', 'role': 'cleaner'},
        },
      );
      final dataSource = _dataSource(adapter);

      final session = await dataSource.loginCleaner(
        phoneNumber: '+79990000003',
        code: '111111',
      );

      expect(adapter.lastOptions?.path, '/api/v1/cleaner/auth/login');
      expect(adapter.lastOptions?.data, {
        'phone': '+79990000003',
        'code': '111111',
      });
      expect(session.accessToken, '2|plain-text-token');
      expect(session.role, UserRole.cleaner);
    });
  });
}

AuthRemoteDataSource _dataSource(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'))
    ..httpClientAdapter = adapter;
  return AuthRemoteDataSource(apiClient: ApiClient(dio: dio));
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.responseJson});

  final Map<String, dynamic> responseJson;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;

    return ResponseBody.fromString(
      jsonEncode(responseJson),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
