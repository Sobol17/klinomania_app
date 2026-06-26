import 'package:dio/dio.dart';

import '../models/address_suggestion_model.dart';

class AddressSuggestService {
  AddressSuggestService({
    Dio? dio,
    String apiKey = '57f8dafe-0a08-4dc1-adcd-fa723496f369',
  }) : _dio = dio ?? Dio(_defaultOptions),
       _apiKey = apiKey;

  final Dio _dio;
  final String _apiKey;

  static final BaseOptions _defaultOptions = BaseOptions(
    baseUrl: 'https://suggest-maps.yandex.ru',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    responseType: ResponseType.json,
  );

  Future<List<AddressSuggestionModel>> fetchSuggestions(String query) async {
    final trimmedQuery = query.trim();
    if (_apiKey.trim().isEmpty || trimmedQuery.isEmpty) {
      return const [];
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/suggest',
      queryParameters: {
        'apikey': _apiKey,
        'text': 'Москва, $trimmedQuery',
        'lang': 'ru',
        'results': 5,
        'highlight': 0,
        'countries': 'ru',
        'types': 'house',
        'print_address': 1,
      },
    );

    final data = response.data;
    final results = data?['results'];
    if (results is! List) {
      return const [];
    }

    return results
        .whereType<Map>()
        .map(
          (item) =>
              AddressSuggestionModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((suggestion) => suggestion.address.trim().isNotEmpty)
        .toList(growable: false);
  }
}
