import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/core/network/api_client.dart';
import 'package:klinomania/src/features/services/data/datasources/services_remote_data_source.dart';

void main() {
  test('loads services from the API data envelope', () async {
    final adapter = _Adapter({
      'data': [
        {
          'id': 'standard',
          'title': 'Базовый минимум',
          'cleaners_label': '1 клинер',
          'duration_label': '2–3 часа',
          'price_from': 7700,
        },
      ],
    });
    final source = ServicesRemoteDataSource(apiClient: _client(adapter));

    final services = await source.fetchServices();

    expect(adapter.request?.path, '/api/v1/client/services');
    expect(services.single.id, 'standard');
    expect(services.single.priceFrom, 7700);
  });

  test('loads service detail and reads API pricing metadata', () async {
    final adapter = _Adapter({
      'data': {
        'id': 'standard',
        'title': 'Базовый минимум',
        'checklist': [
          {'zone': 'everywhere', 'text': 'Пылесосим/моем пол и плинтус'},
          {'zone': 'rooms', 'text': 'Моем зеркала и стеклянные поверхности'},
        ],
        'checklist_sections': [
          {'zone': 'rooms', 'title': 'Комнаты'},
          {'zone': 'everywhere', 'title': 'Везде'},
        ],
        'pricing': {'area_step': 5},
        'room_options': [
          {'id': 'room-2', 'title': '2-комнатная', 'sort_order': 20},
        ],
        'cleaning_options': [],
        'extra_options': [],
      },
    });
    final source = ServicesRemoteDataSource(apiClient: _client(adapter));

    final detail = await source.fetchServiceDetail('standard');

    expect(adapter.request?.path, '/api/v1/client/services/standard');
    expect(detail.pricing?.areaStep, 5);
    expect(detail.roomOptions.single.sortOrder, 20);
    expect(detail.checklist.map((section) => section.title), [
      'Комнаты',
      'Везде',
    ]);
    expect(detail.checklist.first.items, [
      'Моем зеркала и стеклянные поверхности',
    ]);
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
