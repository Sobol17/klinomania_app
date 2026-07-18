import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/network/checklist_incomplete_exception.dart';
import '../models/cleaner_order_item_model.dart';

class CleanerOrdersRemoteDataSource {
  CleanerOrdersRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> acceptOrder(String orderId) => _post('$orderId/accept');

  Future<void> startOrder(String orderId) => _post('$orderId/start');

  Future<void> completeOrder(String orderId) => _post('$orderId/complete');

  Future<void> updateChecklistItem({
    required String orderId,
    required String itemId,
  }) async {
    try {
      await _apiClient.patch<void>(
        '/api/v1/cleaner/orders/$orderId/checklist/$itemId',
        data: const {'completed': true},
      );
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<CleanerOrderItemModel> fetchOrderDetails(String publicId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/cleaner/orders/$publicId',
      );
      final data = response.data?['data'];
      if (data is! Map) {
        throw StateError('Некорректный ответ сервера');
      }
      return CleanerOrderItemModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<List<CleanerOrderItemModel>> fetchOrders() async {
    try {
      final responses = await Future.wait([
        _apiClient.get<Map<String, dynamic>>(
          '/api/v1/cleaner/orders/available',
        ),
        _apiClient.get<Map<String, dynamic>>('/api/v1/cleaner/orders'),
      ]);
      final orders = <String, CleanerOrderItemModel>{
        for (final response in responses)
          for (final item in _parseItems(response.data?['data'])) item.id: item,
      };
      return orders.values.toList(growable: false);
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<void> _post(String action) async {
    try {
      await _apiClient.post<void>('/api/v1/cleaner/orders/$action');
    } on DioException catch (error) {
      if (_isChecklistIncomplete(error)) {
        throw const ChecklistIncompleteException();
      }
      throw StateError(mapDioError(error));
    }
  }

  bool _isChecklistIncomplete(DioException error) {
    if (error.response?.statusCode != 409) return false;
    final data = error.response?.data;
    return data is Map && data['code'] == 'checklist_incomplete';
  }

  List<CleanerOrderItemModel> _parseItems(dynamic data) {
    if (data is! List) {
      throw StateError('Некорректный ответ сервера');
    }
    return data
        .whereType<Map>()
        .map(
          (item) =>
              CleanerOrderItemModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }
}
