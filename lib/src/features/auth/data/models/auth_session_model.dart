import 'dart:convert';

import '../../domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.tokenType,
    required this.phoneNumber,
    required this.isNewUser,
    required this.role,
  });

  final String accessToken;
  final String tokenType;
  final String phoneNumber;
  final bool isNewUser;
  final UserRole role;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final dynamic roleValue =
        json['role'] ?? json['user_role'] ?? json['userRole'];
    return AuthSessionModel(
      accessToken:
          json['access_token'] as String? ??
          json['accessToken'] as String? ??
          '',
      tokenType:
          json['token_type'] as String? ??
          json['tokenType'] as String? ??
          'Bearer',
      phoneNumber:
          json['phone_number'] as String? ??
          json['phoneNumber'] as String? ??
          '',
      isNewUser:
          json['is_new_user'] as bool? ?? json['isNewUser'] as bool? ?? false,
      role: UserRoleSerializer.fromJson(roleValue is String ? roleValue : null),
    );
  }

  factory AuthSessionModel.fromJsonString(String data) {
    return AuthSessionModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'phone_number': phoneNumber,
      'is_new_user': isNewUser,
      'role': UserRoleSerializer.toJson(role),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  AuthSession toEntity() {
    return AuthSession(
      accessToken: accessToken,
      tokenType: tokenType,
      phoneNumber: phoneNumber,
      isNewUser: isNewUser,
      role: role,
    );
  }

  factory AuthSessionModel.fromEntity(AuthSession entity) {
    return AuthSessionModel(
      accessToken: entity.accessToken,
      tokenType: entity.tokenType,
      phoneNumber: entity.phoneNumber,
      isNewUser: entity.isNewUser,
      role: entity.role,
    );
  }
}
