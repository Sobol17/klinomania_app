import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthTermsText extends StatelessWidget {
  const AuthTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      height: 1.35,
    );
    final linkStyle = textStyle?.copyWith(
      color: AppColors.primary,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        text: 'При регистрации и входе вы соглашаетесь с ',
        style: textStyle,
        children: [
          TextSpan(text: 'условиями использования', style: linkStyle),
          const TextSpan(text: ' и '),
          TextSpan(text: 'политикой конфиденциальности.', style: linkStyle),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
