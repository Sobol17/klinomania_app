import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/core/network/api_client.dart';
import 'package:klinomania/src/features/orders/data/datasources/order_history_remote_data_source.dart';

void main() {
  test('fetches a client order by public id', () async {
    final adapter = _Adapter({
      'data': {
        'public_id': 'order-public-id',
        'status': 'confirmed',
        'scheduled_at': '2026-07-23T10:00:00Z',
      },
    });
    final dataSource = OrderHistoryRemoteDataSource(
      apiClient: _client(adapter),
    );

    final order = await dataSource.fetchOrder('order-public-id');

    expect(adapter.request?.path, '/api/v1/client/orders/order-public-id');
    expect(adapter.request?.method, 'GET');
    expect(order.id, 'order-public-id');
  });

  test('requests and maps a T-Bank payment link', () async {
    final adapter = _Adapter({
      'data': {
        'id': 'pay_01J2QM1R7H7YV9JH1KACD6ZK3R',
        'payment_url': 'https://securepay.tinkoff.ru/new/payment',
        'expires_at': '2026-07-19T12:00:00Z',
        'status': 'pending',
      },
    });
    final source = OrderHistoryRemoteDataSource(apiClient: _client(adapter));

    final payment = await source.requestPaymentLink('order-public-id');

    expect(adapter.request?.method, 'POST');
    expect(
      adapter.request?.path,
      '/api/v1/client/orders/order-public-id/payment',
    );
    expect(payment.id, 'pay_01J2QM1R7H7YV9JH1KACD6ZK3R');
    expect(payment.paymentUrl.host, 'securepay.tinkoff.ru');
    expect(payment.status, 'pending');
  });

  test('rejects a non-HTTPS payment link', () async {
    final adapter = _Adapter({
      'data': {
        'id': 'pay-1',
        'payment_url': 'http://securepay.tinkoff.ru/new/payment',
        'expires_at': '2026-07-19T12:00:00Z',
        'status': 'pending',
      },
    });
    final source = OrderHistoryRemoteDataSource(apiClient: _client(adapter));

    expect(
      () => source.requestPaymentLink('order-public-id'),
      throwsA(isA<StateError>()),
    );
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
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
