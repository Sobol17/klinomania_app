import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../domain/entities/payment_operation.dart';
import '../models/order_history_item_model.dart';

class OrderHistoryRemoteDataSource {
  OrderHistoryRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<OrderHistoryItemModel>> fetchHistory() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/client/orders',
      );
      final data = response.data?['data'];
      if (data is! List) {
        throw StateError('Некорректный ответ сервера');
      }
      return data
          .whereType<Map>()
          .map(
            (item) =>
                OrderHistoryItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<OrderHistoryItemModel> fetchOrder(String orderId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/client/orders/$orderId',
      );
      final data = response.data?['data'];
      if (data is! Map) {
        throw StateError('Некорректный ответ сервера');
      }
      return OrderHistoryItemModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _apiClient.post<void>('/api/v1/client/orders/$orderId/cancel');
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<PaymentOperation> requestPaymentLink(String orderId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/client/orders/$orderId/payment',
      );
      final data = response.data?['data'];
      if (data is! Map) {
        throw StateError('Некорректный ответ сервера');
      }

      final paymentUrl = Uri.tryParse(data['payment_url']?.toString() ?? '');
      final expiresAt = DateTime.tryParse(data['expires_at']?.toString() ?? '');
      final id = data['id']?.toString() ?? '';
      if (id.isEmpty ||
          paymentUrl == null ||
          paymentUrl.scheme != 'https' ||
          paymentUrl.host.isEmpty ||
          expiresAt == null) {
        throw StateError('Некорректный ответ сервера');
      }

      return PaymentOperation(
        id: id,
        paymentUrl: paymentUrl,
        expiresAt: expiresAt,
        status: data['status']?.toString() ?? '',
      );
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }
}
