import '../../domain/entities/client_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.remoteDataSource});

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<ClientProfile> fetchProfile() async {
    final profile = await remoteDataSource.fetchProfile();
    return profile.toEntity();
  }

  @override
  Future<ClientProfile> updateProfile({
    String? name,
    String? email,
    String? address,
    String? description,
  }) async {
    final profile = await remoteDataSource.updateProfile(
      name: name,
      email: email,
      address: address,
      description: description,
    );
    return profile.toEntity();
  }
}
