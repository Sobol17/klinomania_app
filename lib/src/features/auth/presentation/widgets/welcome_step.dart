import 'package:flutter/material.dart';
import 'package:klinomania/src/core/theme/app_colors.dart';

import 'auth_brand_card.dart';
import 'cta_button.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({
    super.key,
    required this.onSelectCleaner,
    required this.onSelectClient,
  });

  final VoidCallback onSelectCleaner;
  final VoidCallback onSelectClient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 40),
        const AuthBrandCard(),
        const SizedBox(height: 48),
        CTAButton(label: 'Начать уборку', onPressed: onSelectClient),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: onSelectCleaner,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Войти как клинер'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
