import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/core/network/api_client.dart';

void main() {
  test(
    'clears the application session through handler on a 401 response',
    () async {
      final dio = Dio()..httpClientAdapter = _UnauthorizedAdapter();
      final client = ApiClient(dio: dio);
      var unauthorizedCalls = 0;
      client.setUnauthorizedHandler(() async {
        unauthorizedCalls++;
      });

      await expectLater(
        client.get<void>('/profile'),
        throwsA(isA<DioException>()),
      );

      expect(unauthorizedCalls, 1);
    },
  );
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('', 401);
  }

  @override
  void close({bool force = false}) {}
}
