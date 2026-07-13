import 'package:flutter/material.dart';

import '../../../auth/domain/entities/auth_session.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/entities/profile_menu_item.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required this.repository});

  final ProfileRepository repository;

  ClientProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoaded = false;
  UserRole? _role;
  String? _sessionKey;
  String? _loadError;
  String? _updateError;

  final List<ProfileMenuItem> primaryMenuItems = const [
    ProfileMenuItem(
      action: ProfileMenuAction.personalData,
      title: 'Личные данные',
    ),
    ProfileMenuItem(action: ProfileMenuAction.settings, title: 'Настройки'),
    ProfileMenuItem(action: ProfileMenuAction.history, title: 'История уборки'),
  ];

  final List<ProfileMenuItem> supportMenuItems = const [
    ProfileMenuItem(action: ProfileMenuAction.contacts, title: 'Контакты'),
    ProfileMenuItem(
      action: ProfileMenuAction.legal,
      title: 'Правовая информация',
    ),
    ProfileMenuItem(
      action: ProfileMenuAction.logout,
      title: 'Выйти из аккаунта',
      isDestructive: true,
    ),
  ];

  ClientProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get loadError => _loadError;
  String? get updateError => _updateError;

  void ensureLoaded({required UserRole role, required String sessionKey}) {
    if (sessionKey.isEmpty) {
      return;
    }

    if (_role != role || _sessionKey != sessionKey) {
      _role = role;
      _sessionKey = sessionKey;
      _profile = null;
      _hasLoaded = false;
      _loadError = null;
    }

    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    loadProfile(role);
  }

  Future<void> loadProfile(UserRole role) async {
    if (_isLoading) return;
    _role = role;
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      _profile = await repository.fetchProfile(role);
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
    bool? pushNotificationsEnabled,
    bool? emailMarketingEnabled,
  }) async {
    if (_isSaving) return false;
    final profile = _profile;
    if (profile == null) {
      _updateError = 'Профиль еще не загружен';
      notifyListeners();
      return false;
    }
    if (profile.role != UserRole.client) {
      _updateError = 'Редактирование профиля клинера недоступно';
      notifyListeners();
      return false;
    }

    _updateError = null;
    _isSaving = true;
    notifyListeners();

    try {
      _profile = await repository.updateProfile(
        name: name,
        email: email,
        address: address,
        pushNotificationsEnabled: pushNotificationsEnabled,
        emailMarketingEnabled: emailMarketingEnabled,
      );
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

  static String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return 'Что-то пошло не так. Попробуйте снова';
  }
}
