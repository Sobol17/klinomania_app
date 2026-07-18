import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/cleaner_order_item_model.dart';

class CleanerOrderHistoryRemoteDataSource {
  CleanerOrderHistoryRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<CleanerOrderItemModel>> fetchHistory() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/cleaner/orders/history',
      );
      final data = response.data?['data'];
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
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }
}
