import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiquidWavePainter extends CustomPainter {
  final double wavePhase; // 0.0 to 2*PI
  final double fillPercentage; // 0.0 to 1.0 (or > 1.0)
  final Color primaryColor;
  final Color secondaryColor;

  LiquidWavePainter({
    required this.wavePhase,
    required this.fillPercentage,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // Circular clip path for the liquid container
    final Path clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    // Calculate water baseline Y (0% fill = bottom, 100% fill = top)
    final double clampedFill = fillPercentage.clamp(0.0, 1.0);
    final double waterLevelY = size.height * (1.0 - clampedFill);

    if (clampedFill <= 0.01) {
      // Empty water puddle at bottom
      final paint = Paint()..color = secondaryColor.withValues(alpha: 0.15);
      canvas.drawCircle(center, radius, paint);
      return;
    }

    final double waveHeight = 8.0 * (1.0 - (clampedFill - 0.5).abs() * 1.5).clamp(0.2, 1.0);

    // Wave 1: Back Wave
    final Path backWavePath = Path();
    backWavePath.moveTo(0, size.height);
    backWavePath.lineTo(0, waterLevelY);

    for (double x = 0; x <= size.width; x += 1) {
      final double y = waterLevelY +
          math.sin((x / size.width * 2 * math.pi) + wavePhase + 1.5) * waveHeight;
      backWavePath.lineTo(x, y);
    }

    backWavePath.lineTo(size.width, size.height);
    backWavePath.close();

    final Paint backPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          secondaryColor.withValues(alpha: 0.35),
          primaryColor.withValues(alpha: 0.55),
        ],
      ).createShader(Rect.fromLTWH(0, waterLevelY - waveHeight, size.width, size.height));

    canvas.drawPath(backWavePath, backPaint);

    // Wave 2: Front Wave
    final Path frontWavePath = Path();
    frontWavePath.moveTo(0, size.height);
    frontWavePath.lineTo(0, waterLevelY);

    for (double x = 0; x <= size.width; x += 1) {
      final double y = waterLevelY +
          math.sin((x / size.width * 2 * math.pi) + wavePhase) * waveHeight;
      frontWavePath.lineTo(x, y);
    }

    frontWavePath.lineTo(size.width, size.height);
    frontWavePath.close();

    final Paint frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.50),
          secondaryColor.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromLTWH(0, waterLevelY - waveHeight, size.width, size.height));

    canvas.drawPath(frontWavePath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidWavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.primaryColor != primaryColor;
  }
}
