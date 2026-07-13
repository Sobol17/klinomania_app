import 'package:dio/dio.dart';

import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> requestOtp(String phoneNumber, String role) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/client/auth/request-code',
        data: {'phone': phoneNumber},
      );
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<void> requestOtpSms(String phoneNumber) async {
    await requestOtp(phoneNumber, 'client');
  }

  Future<AuthSessionModel> verifyOtp(String phoneNumber, String code) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/client/auth/verify-code',
        data: {'phone': phoneNumber, 'code': code},
      );

      return AuthSessionModel.fromJson(_responseData(response.data));
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<AuthSessionModel> loginCleaner({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/cleaner/auth/login',
        data: {'phone': phoneNumber, 'code': code},
      );

      return AuthSessionModel.fromJson(_responseData(response.data));
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  void setAuthToken(String? token, {String tokenType = 'Bearer'}) {
    _apiClient.setAuthToken(token, tokenType: tokenType);
  }

  Map<String, dynamic> _responseData(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('Пустой ответ сервера');
    }

    return data;
  }
}
