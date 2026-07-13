import '../../../auth/domain/entities/auth_session.dart';
import '../entities/client_profile.dart';

abstract class ProfileRepository {
  Future<ClientProfile> fetchProfile(UserRole role);
  Future<ClientProfile> updateProfile({
    String? name,
    String? email,
    String? address,
    bool? pushNotificationsEnabled,
    bool? emailMarketingEnabled,
  });
}
