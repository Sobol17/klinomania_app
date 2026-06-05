import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:time2clean/src/core/theme/app_colors.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surface, AppColors.background],
        ),
      ),
      child: CustomPaint(
        painter: _HomeBackgroundPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HomeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.05);
    final List<_ArcSpec> arcs = [
      _ArcSpec(radiusFactor: 1.05, strokeWidth: 34, opacity: 0.18),
      _ArcSpec(radiusFactor: 0.95, strokeWidth: 28, opacity: 0.16),
      _ArcSpec(radiusFactor: 0.85, strokeWidth: 24, opacity: 0.14),
      _ArcSpec(radiusFactor: 0.75, strokeWidth: 22, opacity: 0.12),
    ];

    for (final arc in arcs) {
      final double radius = size.width * arc.radiusFactor;
      final Rect rect = Rect.fromCircle(center: center, radius: radius);
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = arc.strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: arc.opacity * 0.6),
            AppColors.accent.withValues(alpha: arc.opacity),
          ],
        ).createShader(rect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _sigma(18));

      canvas.drawArc(rect, math.pi, math.pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  double _sigma(double radius) => radius * 0.57735 + 0.5;
}

class _ArcSpec {
  const _ArcSpec({
    required this.radiusFactor,
    required this.strokeWidth,
    required this.opacity,
  });

  final double radiusFactor;
  final double strokeWidth;
  final double opacity;
}
