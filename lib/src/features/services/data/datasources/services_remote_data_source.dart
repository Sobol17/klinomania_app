import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/service_detail_model.dart';
import '../models/service_model.dart';

class ServicesRemoteDataSource {
  ServicesRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ServiceModel>> fetchServices() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/client/services',
      );
      final data = _data(response.data);
      if (data is! List) throw StateError('Некорректный ответ сервера');
      return data
          .whereType<Map>()
          .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.id.isNotEmpty && item.title.isNotEmpty)
          .toList(growable: false);
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<ServiceDetailModel> fetchServiceDetail(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/v1/client/services/$id',
      );
      final data = _data(response.data);
      if (data is! Map) throw StateError('Некорректный ответ сервера');
      return ServiceDetailModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Object? _data(Map<String, dynamic>? response) {
    if (response == null || !response.containsKey('data')) {
      throw StateError('Пустой ответ сервера');
    }
    return response['data'];
  }
}
