import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/core/network/api_client.dart';
import 'package:klinomania/src/features/auth/domain/entities/auth_session.dart';
import 'package:klinomania/src/features/profile/data/datasources/profile_remote_data_source.dart';

void main() {
  group('ProfileRemoteDataSource', () {
    test('fetches client profile', () async {
      final adapter = _FakeAdapter(responseJson: _clientProfileJson);
      final dataSource = _dataSource(adapter);

      final profile = await dataSource.fetchProfile(UserRole.client);

      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.path, '/api/v1/client/profile');
      expect(profile.role, UserRole.client);
      expect(profile.phone, '+79990000001');
    });

    test('fetches cleaner profile', () async {
      final adapter = _FakeAdapter(responseJson: _cleanerProfileJson);
      final dataSource = _dataSource(adapter);

      final profile = await dataSource.fetchProfile(UserRole.cleaner);

      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.path, '/api/v1/cleaner/profile');
      expect(profile.role, UserRole.cleaner);
      expect(profile.isActive, isTrue);
    });

    test('updates client profile', () async {
      final adapter = _FakeAdapter(responseJson: _clientProfileJson);
      final dataSource = _dataSource(adapter);

      await dataSource.updateClientProfile(
        name: 'Иван',
        email: 'ivan@example.com',
        address: 'Москва, ул. Тверская, 1',
        pushNotificationsEnabled: true,
        emailMarketingEnabled: false,
      );

      expect(adapter.lastOptions?.method, 'PATCH');
      expect(adapter.lastOptions?.path, '/api/v1/client/profile');
      expect(adapter.lastOptions?.data, {
        'name': 'Иван',
        'email': 'ivan@example.com',
        'address': 'Москва, ул. Тверская, 1',
        'push_notifications_enabled': true,
        'email_marketing_enabled': false,
      });
    });
  });
}

const _clientProfileJson = {
  'data': {
    'id': 1,
    'name': 'Иван',
    'email': 'ivan@example.com',
    'phone': '+79990000001',
    'role': 'client',
    'client_profile': {
      'id': 1,
      'user_id': 1,
      'name': 'Иван',
      'address': 'Москва, ул. Тверская, 1',
      'push_notifications_enabled': true,
      'email_marketing_enabled': false,
    },
  },
};

const _cleanerProfileJson = {
  'data': {
    'id': 2,
    'name': 'Cleaner',
    'email': null,
    'phone': '+79990000003',
    'role': 'cleaner',
    'cleaner_profile': {'id': 1, 'user_id': 2, 'name': null, 'is_active': true},
  },
};

ProfileRemoteDataSource _dataSource(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'))
    ..httpClientAdapter = adapter;
  return ProfileRemoteDataSource(apiClient: ApiClient(dio: dio));
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
