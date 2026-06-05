import 'package:equatable/equatable.dart';

enum UserRole { client, cleaner }

class UserRoleSerializer {
  const UserRoleSerializer._();

  static String toJson(UserRole role) {
    switch (role) {
      case UserRole.cleaner:
        return 'cleaner';
      case UserRole.client:
        return 'client';
    }
  }

  static UserRole fromJson(String? value) {
    switch (value) {
      case 'cleaner':
        return UserRole.cleaner;
      case 'client':
      default:
        return UserRole.client;
    }
  }
}

class AuthSession extends Equatable {
  const AuthSession({
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

  @override
  List<Object?> get props => [
    accessToken,
    tokenType,
    phoneNumber,
    isNewUser,
    role,
  ];
}
