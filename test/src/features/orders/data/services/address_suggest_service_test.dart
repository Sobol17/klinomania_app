import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/features/orders/data/services/address_suggest_service.dart';

void main() {
  group('AddressSuggestService', () {
    test(
      'returns empty list without network request when API key is empty',
      () async {
        final adapter = _FakeAdapter();
        final dio = Dio()..httpClientAdapter = adapter;
        final service = AddressSuggestService(dio: dio, apiKey: '');

        final suggestions = await service.fetchSuggestions('Ленина 1');

        expect(suggestions, isEmpty);
        expect(adapter.requestCount, 0);
      },
    );

    test('filters suggestions with empty address', () async {
      final adapter = _FakeAdapter(
        responseJson: {
          'results': [
            {
              'title': {'text': 'Иркутск, улица Ленина, 1'},
              'subtitle': {'text': 'Иркутск'},
              'address': {'formatted_address': 'Иркутск, улица Ленина, 1'},
            },
            {
              'title': {'text': ''},
              'subtitle': {'text': 'Иркутск'},
              'address': {'formatted_address': ''},
            },
          ],
        },
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://suggest-maps.yandex.ru'))
        ..httpClientAdapter = adapter;
      final service = AddressSuggestService(dio: dio, apiKey: 'key');

      final suggestions = await service.fetchSuggestions('Ленина 1');

      expect(suggestions, hasLength(1));
      expect(suggestions.single.address, 'Иркутск, улица Ленина, 1');
      expect(adapter.requestCount, 1);
      expect(adapter.lastOptions?.path, '/v1/suggest');
      expect(adapter.lastOptions?.queryParameters['text'], 'Москва, Ленина 1');
    });
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({Map<String, dynamic>? responseJson})
    : responseJson = responseJson ?? const {'results': []};

  final Map<String, dynamic> responseJson;
  int requestCount = 0;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
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
