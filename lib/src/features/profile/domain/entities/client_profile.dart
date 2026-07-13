import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/auth_session.dart';

class ClientProfile extends Equatable {
  const ClientProfile({
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

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    role,
    address,
    pushNotificationsEnabled,
    emailMarketingEnabled,
    isActive,
  ];
}
