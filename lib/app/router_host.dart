import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../src/core/theme/app_theme.dart';
import '../src/features/auth/presentation/controllers/auth_controller.dart';
import '../src/features/auth/presentation/pages/auth_page.dart';
import '../src/features/home/presentation/pages/home_page.dart';
import '../src/features/notifications/presentation/controllers/push_notification_controller.dart';
import '../src/features/orders/presentation/pages/order_details_route_page.dart';

class RouterHost extends StatefulWidget {
  const RouterHost({super.key});

  @override
  State<RouterHost> createState() => _RouterHostState();
}

class _RouterHostState extends State<RouterHost> {
  AuthController? _authController;
  PushNotificationController? _pushController;
  GoRouter? _router;
  bool _pushNavigationScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<AuthController>();
    final pushController = context.read<PushNotificationController>();
    if (_authController == controller && _pushController == pushController) {
      return;
    }

    _authController?.removeListener(_handleNavigationStateChanged);
    _pushController?.removeListener(_handleNavigationStateChanged);
    _router?.dispose();
    _authController = controller;
    _pushController = pushController;
    controller.addListener(_handleNavigationStateChanged);
    pushController.addListener(_handleNavigationStateChanged);
    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: controller,
      redirect: (context, state) {
        final location = state.matchedLocation;
        if (controller.isRestoringSession) {
          return location == '/splash' ? null : '/splash';
        }

        if (controller.isAuthenticated) {
          if (location == '/splash' || location == '/auth') {
            return '/home';
          }
          return null;
        }

        return location == '/auth' ? null : '/auth';
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
        GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/orders/:orderId',
          builder: (context, state) =>
              OrderDetailsRoutePage(orderId: state.pathParameters['orderId']!),
        ),
      ],
    );
    _handleNavigationStateChanged();
  }

  void _handleNavigationStateChanged() {
    final authController = _authController;
    final pushController = _pushController;
    if (_pushNavigationScheduled ||
        authController == null ||
        pushController == null ||
        authController.isRestoringSession ||
        !authController.isAuthenticated ||
        pushController.pendingOrderId == null) {
      return;
    }

    _pushNavigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushNavigationScheduled = false;
      if (!mounted || !_authController!.isAuthenticated) {
        return;
      }
      final orderId = _pushController!.takePendingOrderId();
      if (orderId == null) {
        return;
      }
      _router?.push('/orders/${Uri.encodeComponent(orderId)}');
    });
  }

  @override
  void dispose() {
    _authController?.removeListener(_handleNavigationStateChanged);
    _pushController?.removeListener(_handleNavigationStateChanged);
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Klinomania',
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [Locale('ru', 'RU')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      routerConfig: _router!,
    );
  }
}
