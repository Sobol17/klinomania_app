import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        CTAButton(
          label: 'Я Клинер',
          onPressed: onSelectCleaner,
          leading: SvgPicture.asset(
            'assets/icons/cleaning.svg',
            height: 20,
            width: 20,
          ),
        ),
        const SizedBox(height: 16),
        CTAButton(
          label: 'Я Клиент',
          onPressed: onSelectClient,
          variant: CTAButtonVariant.outline,
          leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
