import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';

class PushTokenRemoteDataSource {
  PushTokenRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> registerToken(String token) async {
    try {
      await _apiClient.post<void>(
        '/api/v1/client/push-token',
        data: {'token': token},
      );
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }
}
