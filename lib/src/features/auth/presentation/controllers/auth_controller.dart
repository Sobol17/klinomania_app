import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStep { welcome, phoneInput, otpInput, infoFill, authenticated }

class AuthController extends ChangeNotifier {
  AuthController({required this.repository, this.useApi = true});

  final AuthRepository repository;
  final bool useApi;

  AuthStep _step = AuthStep.welcome;
  bool _isLoading = false;
  String? _errorMessage;
  String _phoneNumber = '';
  AuthSession? _session;
  UserRole _role = UserRole.client;
  String? _lastSubmittedName;
  String? _lastSubmittedEmail;
  String? _lastSubmittedAddress;
  String? _lastSubmittedDistrict;

  AuthStep get step => _step;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get phoneNumber => _phoneNumber;
  AuthSession? get session => _session;
  UserRole get role => _role;
  bool get isAuthenticated => _step == AuthStep.authenticated;
  String? get lastSubmittedName => _lastSubmittedName;
  String? get lastSubmittedEmail => _lastSubmittedEmail;
  String? get lastSubmittedAddress => _lastSubmittedAddress;
  String? get lastSubmittedDistrict => _lastSubmittedDistrict;

  void _setStep(AuthStep step) {
    _step = step;
    notifyListeners();
  }

  void start(UserRole role) {
    _role = role;
    _setStep(AuthStep.phoneInput);
  }

  void backToWelcome() {
    _phoneNumber = '';
    _errorMessage = null;
    _role = UserRole.client;
    _setStep(AuthStep.welcome);
  }

  void backToPhone() {
    _errorMessage = null;
    _setStep(AuthStep.phoneInput);
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> restoreSession() async {
    final restoredSession = await repository.restoreSession();
    if (restoredSession == null) {
      _setStep(AuthStep.welcome);
      return;
    }

    _session = restoredSession;
    _role = restoredSession.role;
    _setStep(AuthStep.authenticated);
  }

  Future<void> submitPhone(String phone) async {
    _phoneNumber = phone;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (useApi) {
        await repository.requestOtp(phone, _role);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
      _step = AuthStep.otpInput;
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestSmsCode() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (useApi) {
        await repository.requestOtp(_phoneNumber, _role);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitCode(String code) async {
    if (_phoneNumber.isEmpty) {
      _errorMessage = 'Введите номер телефона';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final UserRole sessionRole = _role;
      AuthSession session;
      if (useApi) {
        final remoteSession = await repository.verifyOtp(_phoneNumber, code);
        session = AuthSession(
          accessToken: remoteSession.accessToken,
          tokenType: remoteSession.tokenType,
          phoneNumber: remoteSession.phoneNumber,
          isNewUser: remoteSession.isNewUser,
          role: sessionRole,
        );
      } else {
        session = AuthSession(
          accessToken: 'offline_${DateTime.now().millisecondsSinceEpoch}',
          tokenType: 'Bearer',
          phoneNumber: _phoneNumber,
          isNewUser: true,
          role: sessionRole,
        );
      }

      await repository.saveSession(session);
      _applySession(session);
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeInfoFill({
    required String name,
    required String email,
    required String address,
    required String district,
  }) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      _lastSubmittedName = name;
      _lastSubmittedEmail = email;
      _lastSubmittedAddress = address;
      _lastSubmittedDistrict = district;
      if (useApi) {
        await repository.completeProfile(
          name: name,
          email: email,
          address: address,
          district: district,
        );
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      if (_session != null) {
        final updatedSession = AuthSession(
          accessToken: _session!.accessToken,
          tokenType: _session!.tokenType,
          phoneNumber: _session!.phoneNumber,
          isNewUser: false,
          role: _session!.role,
        );
        await repository.saveSession(updatedSession);
        _applySession(updatedSession);
      } else {
        _setStep(AuthStep.authenticated);
      }
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repository.clearSession();
    _session = null;
    _phoneNumber = '';
    _role = UserRole.client;
    _setStep(AuthStep.phoneInput);
  }

  void _applySession(AuthSession session) {
    _session = session;
    _role = session.role;
    if (session.isNewUser) {
      _step = AuthStep.infoFill;
    } else {
      _step = AuthStep.authenticated;
    }
  }

  String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return 'Что-то пошло не так. Попробуйте снова';
  }
}
