import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../storage/preferences_storage.dart';

class DeviceTokenService {
  DeviceTokenService({
    required PreferencesStorage preferencesStorage,
    FirebaseMessaging? messaging,
  }) : _preferencesStorage = preferencesStorage,
       _messaging = messaging ?? FirebaseMessaging.instance;

  static const String _storageKey = 'firebase.device_token';

  final PreferencesStorage _preferencesStorage;
  final FirebaseMessaging _messaging;

  String? get cachedToken => _preferencesStorage.getString(_storageKey);
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Future<String?> requestPermissionAndGetToken() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );
    final isAllowed =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!isAllowed) {
      return null;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await _waitForApnsToken();
      if (apnsToken == null) {
        return null;
      }
    }

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }
      await cacheToken(token);
      return token;
    } on FirebaseException catch (error) {
      if (error.code == 'apns-token-not-set') {
        return null;
      }
      rethrow;
    }
  }

  Future<void> cacheToken(String token) async {
    if (token.isEmpty) {
      return;
    }
    await _preferencesStorage.setString(_storageKey, token);
  }

  Future<String?> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 6; attempt++) {
      final token = await _messaging.getAPNSToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return null;
  }
}
