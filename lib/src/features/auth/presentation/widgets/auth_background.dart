import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.65),
          radius: 1.2,
          colors: [AppColors.surface, AppColors.surface, AppColors.lightBlue],
          stops: [0.2, 0.72, 1],
        ),
      ),
      child: Stack(
        children: List.generate(4, (index) {
          final size = (index + 2) * 180.0;
          final opacity = (0.35 - index * 0.05).clamp(0.05, 1.0);
          final shadowOpacity = (0.08 - index * 0.01).clamp(0.0, 1.0);
          return Align(
            alignment: Alignment(0, -0.1 + index * 0.18),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withAlpha((opacity * 255).round()),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightBlue.withAlpha(
                      (shadowOpacity * 255).round(),
                    ),
                    blurRadius: 60,
                    spreadRadius: -20,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
