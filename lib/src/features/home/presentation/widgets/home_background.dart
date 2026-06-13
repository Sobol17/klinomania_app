import 'package:flutter/material.dart';
import 'package:klinomania/src/core/theme/app_colors.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.accent.withValues(alpha: 0.18),
            AppColors.surface,
          ],
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
    _drawShape(canvas, size, _topMist(size), 36, 0.22);
    _drawShape(canvas, size, _sideMist(size), 52, 0.14);
    _drawShape(canvas, size, _bottomMist(size), 44, 0.16);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  void _drawShape(
    Canvas canvas,
    Size size,
    Path path,
    double blur,
    double opacity,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.lightBlue.withValues(alpha: opacity),
          AppColors.softBlue.withValues(alpha: opacity * 0.55),
          AppColors.surface.withValues(alpha: 0.02),
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, _sigma(blur));

    canvas.drawPath(path, paint);
  }

  Path _topMist(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(-w * 0.18, h * 0.04)
      ..cubicTo(w * 0.08, -h * 0.04, w * 0.28, h * 0.1, w * 0.5, h * 0.05)
      ..cubicTo(w * 0.76, -h * 0.01, w * 0.9, h * 0.12, w * 1.18, h * 0.08)
      ..lineTo(w * 1.18, -h * 0.18)
      ..lineTo(-w * 0.18, -h * 0.18)
      ..close();
  }

  Path _sideMist(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(-w * 0.3, h * 0.25)
      ..cubicTo(w * 0.05, h * 0.18, w * 0.2, h * 0.36, w * 0.44, h * 0.3)
      ..cubicTo(w * 0.64, h * 0.25, w * 0.74, h * 0.39, w * 1.06, h * 0.35)
      ..lineTo(w * 1.04, h * 0.52)
      ..cubicTo(w * 0.7, h * 0.57, w * 0.54, h * 0.42, w * 0.3, h * 0.48)
      ..cubicTo(w * 0.06, h * 0.54, -w * 0.1, h * 0.42, -w * 0.32, h * 0.5)
      ..close();
  }

  Path _bottomMist(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.2, h * 0.74)
      ..cubicTo(w * 0.46, h * 0.68, w * 0.54, h * 0.82, w * 0.8, h * 0.76)
      ..cubicTo(w * 1.0, h * 0.71, w * 1.1, h * 0.83, w * 1.18, h * 0.96)
      ..lineTo(w * 1.18, h * 1.2)
      ..lineTo(w * 0.16, h * 1.2)
      ..cubicTo(w * 0.02, h * 1.04, -w * 0.04, h * 0.84, w * 0.2, h * 0.74)
      ..close();
  }

  double _sigma(double radius) => radius * 0.57735 + 0.5;
}
