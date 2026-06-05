import '../../../auth/domain/entities/auth_session.dart';
import '../../domain/entities/client_profile.dart';

class ClientProfileModel {
  const ClientProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.dateOfBirth,
    required this.role,
    required this.address,
    required this.district,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final DateTime? dateOfBirth;
  final UserRole role;
  final String address;
  final String district;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    final dynamic roleValue =
        json['role'] ?? json['user_role'] ?? json['userRole'];
    return ClientProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phone_number'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dateOfBirth: _parseDate(json['date_of_birth'] ?? json['dateOfBirth']),
      role: UserRoleSerializer.fromJson(roleValue is String ? roleValue : null),
      address: json['address'] as String? ?? '',
      district: json['district'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  ClientProfile toEntity() {
    return ClientProfile(
      id: id,
      name: name,
      phone: phone,
      email: email,
      dateOfBirth: dateOfBirth,
      role: role,
      address: address,
      district: district,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
