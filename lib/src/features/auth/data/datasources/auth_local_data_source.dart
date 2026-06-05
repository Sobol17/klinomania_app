import '../../../../core/storage/preferences_storage.dart';
import '../models/auth_session_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final PreferencesStorage _storage;

  static const String _sessionKey = 'auth.session';

  Future<void> saveSession(AuthSessionModel session) {
    return _storage.setString(_sessionKey, session.toJsonString());
  }

  Future<AuthSessionModel?> loadSession() async {
    final raw = _storage.getString(_sessionKey);
    if (raw == null) {
      return null;
    }

    try {
      return AuthSessionModel.fromJsonString(raw);
    } on FormatException {
      await _storage.remove(_sessionKey);
      return null;
    }
  }

  Future<void> clearSession() => _storage.remove(_sessionKey);
}
