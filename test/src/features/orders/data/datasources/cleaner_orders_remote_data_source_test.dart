import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/core/network/api_client.dart';
import 'package:klinomania/src/core/network/checklist_incomplete_exception.dart';
import 'package:klinomania/src/features/orders/data/datasources/cleaner_orders_remote_data_source.dart';

void main() {
  test(
    'loads checklist sections in API order with completed item state',
    () async {
      final adapter = _Adapter({
        'data': {
          'id': 'order-1',
          'status': 'awaiting_payment',
          'checklist': [
            {
              'id': 'base-1',
              'kind': 'base_service',
              'zone': 'rooms',
              'text': 'Пылесосим пол',
              'completed': true,
            },
            {
              'id': 'extra-42',
              'kind': 'extra_service',
              'zone': 'kitchen',
              'text': 'Моем холодильник внутри',
              'completed': false,
            },
          ],
          'checklist_sections': [
            {'zone': 'kitchen', 'title': 'Кухня'},
            {'zone': 'rooms', 'title': 'Комнаты'},
          ],
        },
      });
      final source = CleanerOrdersRemoteDataSource(apiClient: _client(adapter));

      final order = await source.fetchOrderDetails('order-1');
      final entity = order.toEntity();

      expect(adapter.request?.path, '/api/v1/cleaner/orders/order-1');
      expect(entity.checklistSections.map((section) => section.title), [
        'Кухня',
        'Комнаты',
      ]);
      expect(entity.checklistSections.first.items.single.id, 'extra-42');
      expect(entity.checklistSections.last.items.single.completed, isTrue);
      expect(entity.isAwaitingPayment, isTrue);
    },
  );

  test('marks a checklist item as completed through PATCH', () async {
    final adapter = _Adapter({'data': {}});
    final source = CleanerOrdersRemoteDataSource(apiClient: _client(adapter));

    await source.updateChecklistItem(orderId: 'order-1', itemId: 'extra-42');

    expect(
      adapter.request?.path,
      '/api/v1/cleaner/orders/order-1/checklist/extra-42',
    );
    expect(adapter.request?.method, 'PATCH');
    expect(adapter.request?.data, {'completed': true});
  });

  test(
    'reports an incomplete checklist conflict when completing an order',
    () async {
      final adapter = _Adapter({
        'code': 'checklist_incomplete',
      }, statusCode: 409);
      final source = CleanerOrdersRemoteDataSource(apiClient: _client(adapter));

      await expectLater(
        source.completeOrder('order-1'),
        throwsA(isA<ChecklistIncompleteException>()),
      );
    },
  );
}

ApiClient _client(_Adapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = adapter;
  return ApiClient(dio: dio);
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body, {this.statusCode = 200});

  final Map<String, dynamic> body;
  final int statusCode;
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
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
