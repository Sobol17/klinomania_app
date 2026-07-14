import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../domain/entities/service_quote.dart';

class OrderCheckoutRemoteDataSource {
  OrderCheckoutRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ServiceQuote> createQuote(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/client/service-quotes',
        data: payload,
      );
      final data = response.data?['data'];
      if (data is! Map) throw StateError('Пустой ответ сервера');
      final id = data['quote_id']?.toString() ?? '';
      if (id.isEmpty) throw StateError('Некорректный ответ сервера');
      final amount = data['total_price'];
      return ServiceQuote(
        id: id,
        totalPrice: amount is num
            ? amount.toDouble()
            : double.tryParse('$amount') ?? 0,
        currency: data['currency']?.toString() ?? 'RUB',
        expiresAt: DateTime.tryParse(data['expires_at']?.toString() ?? ''),
      );
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<void> createOrder({
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/client/orders',
        data: payload,
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }
}
