import '../../../auth/domain/entities/auth_session.dart';
import '../../domain/entities/client_profile.dart';

class ClientProfileModel {
  const ClientProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.address,
    required this.pushNotificationsEnabled,
    required this.emailMarketingEnabled,
    required this.isActive,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String address;
  final bool pushNotificationsEnabled;
  final bool emailMarketingEnabled;
  final bool? isActive;

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final clientProfile = data['client_profile'] is Map
        ? Map<String, dynamic>.from(data['client_profile'] as Map)
        : const <String, dynamic>{};
    final cleanerProfile = data['cleaner_profile'] is Map
        ? Map<String, dynamic>.from(data['cleaner_profile'] as Map)
        : const <String, dynamic>{};
    final dynamic roleValue =
        data['role'] ?? data['user_role'] ?? data['userRole'];
    final name =
        clientProfile['name'] ?? cleanerProfile['name'] ?? data['name'];
    return ClientProfileModel(
      id: data['id']?.toString() ?? '',
      name: name is String ? name : '',
      phone: data['phone'] as String? ?? data['phone_number'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: UserRoleSerializer.fromJson(roleValue is String ? roleValue : null),
      address:
          clientProfile['address'] as String? ??
          data['address'] as String? ??
          '',
      pushNotificationsEnabled:
          clientProfile['push_notifications_enabled'] as bool? ?? false,
      emailMarketingEnabled:
          clientProfile['email_marketing_enabled'] as bool? ?? false,
      isActive: cleanerProfile['is_active'] as bool?,
    );
  }

  ClientProfile toEntity() {
    return ClientProfile(
      id: id,
      name: name,
      phone: phone,
      email: email,
      role: role,
      address: address,
      pushNotificationsEnabled: pushNotificationsEnabled,
      emailMarketingEnabled: emailMarketingEnabled,
      isActive: isActive,
    );
  }
}
