import '../../../auth/domain/entities/auth_session.dart';
import '../models/client_profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource();

  ClientProfileModel _profile = ClientProfileModel(
    id: 'client-1',
    name: 'Анна Смирнова',
    phone: '+7 999 123-45-67',
    email: 'anna@example.com',
    dateOfBirth: DateTime(1993, 5, 18),
    role: UserRole.client,
    address: 'ул. Ленина, 10',
    district: 'Центральный',
    description: '',
    createdAt: DateTime(2026, 1),
    updatedAt: DateTime(2026, 2),
  );

  Future<ClientProfileModel> fetchProfile() async {
    await _mockDelay();
    return _profile;
  }

  Future<ClientProfileModel> updateProfile({
    String? name,
    String? email,
    String? address,
    String? district,
    String? description,
  }) async {
    await _mockDelay();
    _profile = ClientProfileModel(
      id: _profile.id,
      name: name ?? _profile.name,
      phone: _profile.phone,
      email: email ?? _profile.email,
      dateOfBirth: _profile.dateOfBirth,
      role: _profile.role,
      address: address ?? _profile.address,
      district: district ?? _profile.district,
      description: description ?? _profile.description,
      createdAt: _profile.createdAt,
      updatedAt: DateTime.now(),
    );
    return _profile;
  }

  Future<void> _mockDelay() {
    return Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
