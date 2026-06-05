import 'package:flutter/material.dart';

import '../../../auth/domain/entities/auth_session.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/entities/profile_info_field.dart';
import '../../domain/entities/profile_menu_item.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required this.repository, this.useApi = true}) {
    if (!useApi) {
      _profile = _mockProfile;
    }
  }

  final ProfileRepository repository;
  final bool useApi;

  ClientProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoaded = false;
  String? _loadError;
  String? _updateError;

  bool _prefersSlavicStaff = true;

  final List<ProfileMenuItem> menuItems = const [
    ProfileMenuItem(action: ProfileMenuAction.history, title: 'История уборки'),
    ProfileMenuItem(action: ProfileMenuAction.logout, title: 'Выйти'),
  ];

  bool get prefersSlavicStaff => _prefersSlavicStaff;
  ClientProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get loadError => _loadError;
  String? get updateError => _updateError;

  List<ProfileInfoField> get infoFields {
    final profile = _profile;
    return [
      ProfileInfoField(
        type: ProfileInfoFieldType.name,
        label: 'Имя',
        value: _valueOrDash(profile?.name),
        isEditable: true,
      ),
      ProfileInfoField(
        type: ProfileInfoFieldType.phone,
        label: 'Номер телефона',
        value: _valueOrDash(profile?.phone),
      ),
      ProfileInfoField(
        type: ProfileInfoFieldType.email,
        label: 'Эл. почта',
        value: _valueOrDash(profile?.email),
        isEditable: true,
      ),
      ProfileInfoField(
        type: ProfileInfoFieldType.address,
        label: 'Адрес',
        value: _valueOrDash(profile?.address),
        isEditable: true,
      ),
      ProfileInfoField(
        type: ProfileInfoFieldType.district,
        label: 'Район',
        value: _valueOrDash(profile?.district),
        isEditable: true,
      ),
    ];
  }

  void ensureLoaded() {
    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (_isLoading) return;
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      if (useApi) {
        _profile = await repository.fetchProfile();
      } else {
        _profile = _mockProfile;
      }
    } catch (error) {
      _loadError = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? address,
    String? district,
    String? description,
  }) async {
    if (_isSaving) return false;
    _updateError = null;
    _isSaving = true;
    notifyListeners();

    try {
      if (useApi) {
        _profile = await repository.updateProfile(
          name: name,
          email: email,
          address: address,
          district: district,
          description: description,
        );
      } else {
        final current = _profile ?? _mockProfile;
        _profile = ClientProfile(
          id: current.id,
          name: name ?? current.name,
          phone: current.phone,
          email: email ?? current.email,
          dateOfBirth: current.dateOfBirth,
          role: current.role,
          address: address ?? current.address,
          district: district ?? current.district,
          description: description ?? current.description,
          createdAt: current.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return true;
    } catch (error) {
      _updateError = _mapError(error);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearUpdateError() {
    if (_updateError != null) {
      _updateError = null;
      notifyListeners();
    }
  }

  void onMenuItemSelected(ProfileMenuAction action) {}

  void setSlavicStaffPreference(bool value) {
    if (_prefersSlavicStaff == value) return;
    _prefersSlavicStaff = value;
    notifyListeners();
  }

  static String _valueOrDash(String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }
    return value;
  }

  static String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return 'Что-то пошло не так. Попробуйте снова';
  }

  static final ClientProfile _mockProfile = ClientProfile(
    id: 'mock-client',
    name: 'Георгий Феодалов',
    phone: '+7 998 12-632-31',
    email: 'mail@gmail.com',
    dateOfBirth: null,
    role: UserRole.client,
    address: 'ул. Пушкина, 10',
    district: 'Центральный',
    description:
        'Аккуратный и ответственный клинер. Быстро и качественно наведу порядок в любых помещениях.',
    createdAt: null,
    updatedAt: null,
  );
}
