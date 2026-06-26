import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/auth_session.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_terms_text.dart';
import '../widgets/cleaner_login_step.dart';
import '../widgets/otp_step.dart';
import '../widgets/phone_step.dart';
import '../widgets/welcome_step.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthController? _authController;
  HomeController? _homeController;
  bool _wasAuthenticated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authController = context.read<AuthController>();
    final homeController = context.read<HomeController>();

    if (_authController != authController) {
      _authController?.removeListener(_handleAuthChanged);
      _authController = authController;
      _authController!.addListener(_handleAuthChanged);
      _wasAuthenticated = authController.isAuthenticated;
    }

    _homeController = homeController;
  }

  @override
  void dispose() {
    _authController?.removeListener(_handleAuthChanged);
    super.dispose();
  }

  void _handleAuthChanged() {
    final authController = _authController;
    final homeController = _homeController;
    if (authController == null || homeController == null) {
      return;
    }

    final isAuthenticated = authController.isAuthenticated;
    if (isAuthenticated && !_wasAuthenticated) {
      homeController.selectNavigationIndex(HomeController.servicesTabIndex);
    }
    _wasAuthenticated = isAuthenticated;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        final step = controller.step;
        if (step == AuthStep.authenticated) {
          return const HomePage();
        }
        return Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: AuthBackground()),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BackButton(step: step, controller: controller),
                      const SizedBox(height: 12),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: LayoutBuilder(
                            key: ValueKey(step),
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: _buildStep(
                                      step,
                                      controller,
                                      constraints.maxHeight,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (step != AuthStep.authenticated &&
                          step != AuthStep.cleanerLogin &&
                          step != AuthStep.phoneInput) ...[
                        const SizedBox(height: 24),
                        const AuthTermsText(),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep(
    AuthStep step,
    AuthController controller,
    double viewportHeight,
  ) {
    switch (step) {
      case AuthStep.welcome:
        return WelcomeStep(
          onSelectCleaner: controller.startCleanerLogin,
          onSelectClient: () => controller.start(UserRole.client),
        );
      case AuthStep.cleanerLogin:
        return CleanerLoginStep(
          controller: controller,
          viewportHeight: viewportHeight,
        );
      case AuthStep.phoneInput:
        return PhoneStep(
          controller: controller,
          viewportHeight: viewportHeight,
        );
      case AuthStep.otpInput:
        return OtpStep(controller: controller);
      case AuthStep.authenticated:
        return const SizedBox.shrink();
    }
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.step, required this.controller});

  final AuthStep step;
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    if (step == AuthStep.welcome || step == AuthStep.authenticated) {
      return const SizedBox(height: 32);
    }

    VoidCallback? action;
    switch (step) {
      case AuthStep.phoneInput:
        action = controller.backToWelcome;
        break;
      case AuthStep.otpInput:
        action = controller.backToPhone;
        break;
      case AuthStep.cleanerLogin:
        action = controller.backToWelcome;
        break;
      default:
        action = null;
    }

    return GestureDetector(
      onTap: action,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18),
          SizedBox(width: 4),
          Text(
            'Назад',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
