import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStep { welcome, phoneInput, otpInput, cleanerLogin, authenticated }

class AuthController extends ChangeNotifier {
  AuthController({
    required this.repository,
    required ApiClient apiClient,
    this.useApi = true,
  }) : _apiClient = apiClient {
    _apiClient.setUnauthorizedHandler(handleUnauthorized);
  }

  final AuthRepository repository;
  final ApiClient _apiClient;
  final bool useApi;

  AuthStep _step = AuthStep.welcome;
  bool _isLoading = false;
  String? _errorMessage;
  String _phoneNumber = '';
  AuthSession? _session;
  UserRole _role = UserRole.client;
  bool _isRestoringSession = true;
  bool _isClearingUnauthorizedSession = false;

  AuthStep get step => _step;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get phoneNumber => _phoneNumber;
  AuthSession? get session => _session;
  UserRole get role => _role;
  bool get isAuthenticated => _step == AuthStep.authenticated;
  bool get isRestoringSession => _isRestoringSession;

  void _setStep(AuthStep step) {
    _step = step;
    notifyListeners();
  }

  void start(UserRole role) {
    _role = role;
    if (role == UserRole.cleaner) {
      _setStep(AuthStep.cleanerLogin);
      return;
    }
    _setStep(AuthStep.phoneInput);
  }

  void startCleanerLogin() {
    _role = UserRole.cleaner;
    _errorMessage = null;
    _setStep(AuthStep.cleanerLogin);
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

  void backToCleanerLogin() {
    _errorMessage = null;
    _setStep(AuthStep.cleanerLogin);
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> restoreSession() async {
    try {
      final restoredSession = await repository.restoreSession();
      if (restoredSession == null) {
        _step = AuthStep.welcome;
        return;
      }

      _session = restoredSession;
      _role = restoredSession.role;
      _step = AuthStep.authenticated;
    } finally {
      _isRestoringSession = false;
      notifyListeners();
    }
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

  Future<void> submitCleanerCredentials({
    required String phone,
    required String code,
  }) async {
    _phoneNumber = phone;
    _role = UserRole.cleaner;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      AuthSession session;
      if (useApi) {
        session = await repository.loginCleaner(phoneNumber: phone, code: code);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        session = AuthSession(
          accessToken:
              'offline_cleaner_${DateTime.now().millisecondsSinceEpoch}',
          tokenType: 'Bearer',
          phoneNumber: phone,
          isNewUser: false,
          role: UserRole.cleaner,
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

  Future<void> logout() async {
    await repository.clearSession();
    _session = null;
    _phoneNumber = '';
    _role = UserRole.client;
    _setStep(AuthStep.phoneInput);
  }

  /// Called by [ApiClient] after any API response with status code 401.
  Future<void> handleUnauthorized() async {
    if (_isClearingUnauthorizedSession) {
      return;
    }

    _isClearingUnauthorizedSession = true;
    try {
      await repository.clearSession();
      _session = null;
      _phoneNumber = '';
      _role = UserRole.client;
      _errorMessage = null;
      _step = AuthStep.welcome;
      notifyListeners();
    } finally {
      _isClearingUnauthorizedSession = false;
    }
  }

  @override
  void dispose() {
    _apiClient.setUnauthorizedHandler(null);
    super.dispose();
  }

  void _applySession(AuthSession session) {
    _session = session;
    _role = session.role;
    _step = AuthStep.authenticated;
  }

  String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return 'Что-то пошло не так. Попробуйте снова';
  }
}
