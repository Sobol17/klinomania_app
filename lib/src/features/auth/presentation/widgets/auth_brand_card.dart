import 'package:flutter/material.dart';

class AuthBrandCard extends StatelessWidget {
  const AuthBrandCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(220),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
            blurRadius: 40,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/logo.png'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF1F1F1F).withAlpha((0.2 * 255).round()),
              ),
            ),
            child: Text(
              'КЛИНИНГОВЫЙ СЕРВИС',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Быстро, чисто, удобно',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black.withAlpha((0.65 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }
}
