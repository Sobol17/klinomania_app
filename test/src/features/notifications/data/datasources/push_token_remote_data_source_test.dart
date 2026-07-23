import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/core/network/api_client.dart';
import 'package:klinomania/src/features/notifications/data/datasources/push_token_remote_data_source.dart';

void main() {
  test('registers the Firebase device token for a client', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'))
      ..httpClientAdapter = adapter;
    final dataSource = PushTokenRemoteDataSource(
      apiClient: ApiClient(dio: dio),
    );

    await dataSource.registerToken('firebase-device-token');

    expect(adapter.request?.path, '/api/v1/client/push-token');
    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.data, {'token': 'firebase-device-token'});
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({'message': 'Token saved.'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
