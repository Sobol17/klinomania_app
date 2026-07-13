import '../../../auth/domain/entities/auth_session.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.remoteDataSource});

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<ClientProfile> fetchProfile(UserRole role) async {
    final profile = await remoteDataSource.fetchProfile(role);
    return profile.toEntity();
  }

  @override
  Future<ClientProfile> updateProfile({
    String? name,
    String? email,
    String? address,
    bool? pushNotificationsEnabled,
    bool? emailMarketingEnabled,
  }) async {
    final profile = await remoteDataSource.updateClientProfile(
      name: name,
      email: email,
      address: address,
      pushNotificationsEnabled: pushNotificationsEnabled,
      emailMarketingEnabled: emailMarketingEnabled,
    );
    return profile.toEntity();
  }
}
