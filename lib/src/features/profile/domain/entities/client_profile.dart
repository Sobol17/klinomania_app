import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/auth_session.dart';

class ClientProfile extends Equatable {
  const ClientProfile({
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

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    dateOfBirth,
    role,
    address,
    district,
    description,
    createdAt,
    updatedAt,
  ];
}
