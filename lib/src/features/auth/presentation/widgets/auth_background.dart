import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.6),
          radius: 1.2,
          colors: [
            Colors.white,
            theme.colorScheme.surface,
            const Color(0xFFE9F1FF),
          ],
          stops: const [0.2, 0.7, 1],
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
                color: Colors.white.withAlpha((opacity * 255).round()),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF4D7BFE,
                    ).withAlpha((shadowOpacity * 255).round()),
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
