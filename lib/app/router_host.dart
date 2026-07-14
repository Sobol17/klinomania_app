import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../src/core/theme/app_theme.dart';
import '../src/features/auth/presentation/controllers/auth_controller.dart';
import '../src/features/auth/presentation/pages/auth_page.dart';
import '../src/features/home/presentation/pages/home_page.dart';

class RouterHost extends StatefulWidget {
  const RouterHost({super.key});

  @override
  State<RouterHost> createState() => _RouterHostState();
}

class _RouterHostState extends State<RouterHost> {
  AuthController? _authController;
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<AuthController>();
    if (_authController == controller) {
      return;
    }

    _router?.dispose();
    _authController = controller;
    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: controller,
      redirect: (context, state) {
        final location = state.matchedLocation;
        if (controller.isRestoringSession) {
          return location == '/splash' ? null : '/splash';
        }

        if (controller.isAuthenticated) {
          return location == '/home' ? null : '/home';
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
      ],
    );
  }

  @override
  void dispose() {
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
