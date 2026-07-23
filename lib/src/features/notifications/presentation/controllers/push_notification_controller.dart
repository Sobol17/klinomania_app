import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/notifications/device_token_service.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/push_token_remote_data_source.dart';

class PushNotificationController extends ChangeNotifier {
  PushNotificationController({
    required AuthController authController,
    required DeviceTokenService deviceTokenService,
    required PushTokenRemoteDataSource remoteDataSource,
    required bool useApi,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _authController = authController,
       _deviceTokenService = deviceTokenService,
       _remoteDataSource = remoteDataSource,
       _useApi = useApi,
       _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin() {
    _authController.addListener(_handleAuthChanged);
  }

  static const AndroidNotificationChannel _orderStatusChannel =
      AndroidNotificationChannel(
        'order_status',
        'Статусы заявок',
        description: 'Изменения статусов заявок на уборку',
        importance: Importance.high,
      );

  final AuthController _authController;
  final DeviceTokenService _deviceTokenService;
  final PushTokenRemoteDataSource _remoteDataSource;
  final bool _useApi;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  String? _processedSessionKey;
  String? _pendingOrderId;
  bool _initializationStarted = false;
  bool _isDisposed = false;

  String? get pendingOrderId => _pendingOrderId;

  Future<void> initialize() async {
    if (_initializationStarted || _isDisposed) {
      return;
    }
    _initializationStarted = true;
    try {
      await _initialize();
    } catch (error, stackTrace) {
      debugPrint('Push notification initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _queueOrder(response.payload);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_orderStatusChannel);

    final localLaunchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (localLaunchDetails?.didNotificationLaunchApp ?? false) {
      _queueOrder(localLaunchDetails?.notificationResponse?.payload);
    }

    if (_isDisposed) {
      return;
    }
    _tokenRefreshSubscription = _deviceTokenService.onTokenRefresh.listen(
      _handleTokenRefresh,
    );
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedMessage,
    );

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleOpenedMessage(initialMessage);
    }
    await _syncTokenWithSession();
  }

  String? takePendingOrderId() {
    final orderId = _pendingOrderId;
    _pendingOrderId = null;
    return orderId;
  }

  void _handleAuthChanged() {
    unawaited(_syncTokenWithSession());
  }

  Future<void> _syncTokenWithSession() async {
    if (!_canRegisterToken) {
      _processedSessionKey = null;
      return;
    }

    final sessionKey = _authController.session!.accessToken;
    if (_processedSessionKey == sessionKey) {
      return;
    }
    _processedSessionKey = sessionKey;

    try {
      final token = await _deviceTokenService.requestPermissionAndGetToken();
      if (token != null && _canRegisterToken) {
        await _remoteDataSource.registerToken(token);
      }
    } catch (error, stackTrace) {
      debugPrint('Push token registration failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _handleTokenRefresh(String token) async {
    try {
      await _deviceTokenService.cacheToken(token);
      if (_canRegisterToken) {
        await _remoteDataSource.registerToken(token);
      }
    } catch (error, stackTrace) {
      debugPrint('Push token refresh registration failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!_isClientAuthenticated) {
      return;
    }
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'order_status',
          'Статусы заявок',
          channelDescription: 'Изменения статусов заявок на уборку',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
          color: Color(0xFF182846),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _orderIdFrom(message),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    _queueOrder(_orderIdFrom(message));
  }

  String? _orderIdFrom(RemoteMessage message) {
    return message.data['order_id']?.toString();
  }

  void _queueOrder(String? rawOrderId) {
    if (_isDisposed) {
      return;
    }
    final orderId = rawOrderId?.trim();
    if (orderId == null || orderId.isEmpty) {
      return;
    }
    _pendingOrderId = orderId;
    notifyListeners();
  }

  bool get _isClientAuthenticated =>
      _authController.isAuthenticated &&
      _authController.role == UserRole.client;

  bool get _canRegisterToken =>
      !_isDisposed &&
      _useApi &&
      _isClientAuthenticated &&
      _authController.session != null;

  @override
  void dispose() {
    _isDisposed = true;
    _authController.removeListener(_handleAuthChanged);
    unawaited(_tokenRefreshSubscription?.cancel());
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedAppSubscription?.cancel());
    super.dispose();
  }
}
