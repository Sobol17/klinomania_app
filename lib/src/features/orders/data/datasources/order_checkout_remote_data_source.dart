import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';

class OrderCheckoutRemoteDataSource {
  OrderCheckoutRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

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
