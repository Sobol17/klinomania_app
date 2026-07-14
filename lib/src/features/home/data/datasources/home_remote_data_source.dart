import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../domain/entities/home_summary.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<HomeSummary> fetchSummary() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/client/home-summary',
      );
      final body = response.data?['data'];
      if (body is! Map) throw StateError('Пустой ответ сервера');
      final count = body['active_orders_count'];
      return HomeSummary(
        activeOrdersCount: count is num
            ? count.toInt()
            : int.tryParse('$count') ?? 0,
        activeOrderStatus: body['active_order_status']?.toString(),
        activeOrderStatusLabel: body['active_order_status_label']?.toString(),
      );
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }
}
