import '../entities/client_profile.dart';

abstract class ProfileRepository {
  Future<ClientProfile> fetchProfile();
  Future<ClientProfile> updateProfile({
    String? name,
    String? email,
    String? address,
    String? district,
    String? description,
  });
}
