import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../models/client_profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ClientProfileModel> fetchProfile(UserRole role) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _profilePath(role),
      );

      return ClientProfileModel.fromJson(_responseData(response.data));
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  Future<ClientProfileModel> updateClientProfile({
    String? name,
    String? email,
    String? address,
    bool? pushNotificationsEnabled,
    bool? emailMarketingEnabled,
  }) async {
    final data = <String, dynamic>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (pushNotificationsEnabled != null)
        'push_notifications_enabled': pushNotificationsEnabled,
      if (emailMarketingEnabled != null)
        'email_marketing_enabled': emailMarketingEnabled,
    };

    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/api/v1/client/profile',
        data: data,
      );

      return ClientProfileModel.fromJson(_responseData(response.data));
    } on DioException catch (error) {
      throw StateError(mapDioError(error));
    }
  }

  String _profilePath(UserRole role) {
    switch (role) {
      case UserRole.cleaner:
        return '/api/v1/cleaner/profile';
      case UserRole.client:
        return '/api/v1/client/profile';
    }
  }

  Map<String, dynamic> _responseData(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('Пустой ответ сервера');
    }

    return data;
  }
}
