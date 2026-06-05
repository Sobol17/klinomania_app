import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesStorage {
  Future<bool> setString(String key, String value);
  String? getString(String key);
  Future<bool> remove(String key);
}

class SharedPreferencesStorage implements PreferencesStorage {
  SharedPreferencesStorage(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<bool> remove(String key) => _preferences.remove(key);

  @override
  Future<bool> setString(String key, String value) =>
      _preferences.setString(key, value);
}
