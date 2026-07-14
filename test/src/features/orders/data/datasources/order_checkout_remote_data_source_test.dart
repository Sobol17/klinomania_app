import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/core/network/api_client.dart';
import 'package:klinomania/src/features/orders/data/datasources/order_checkout_remote_data_source.dart';

void main() {
  test('sends idempotency key while creating an order', () async {
    final adapter = _Adapter({
      'data': {'id': 'order-1'},
    });
    final source = OrderCheckoutRemoteDataSource(apiClient: _client(adapter));

    await source.createOrder(
      idempotencyKey: 'key-1',
      payload: {'quote_id': 'quote-1'},
    );

    expect(adapter.request?.path, '/api/v1/client/orders');
    expect(adapter.request?.headers['Idempotency-Key'], 'key-1');
    expect(adapter.request?.data, {'quote_id': 'quote-1'});
  });
}

ApiClient _client(_Adapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = adapter;
  return ApiClient(dio: dio);
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body);

  final Map<String, dynamic> body;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
