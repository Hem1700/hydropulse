import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/timer_session.dart';
import '../theme/app_theme.dart';
import 'liquid_wave_painter.dart';

class DualProgressDial extends StatefulWidget {
  final SessionMode mode;
  final int remainingSeconds;
  final int totalSeconds;
  final double timerProgress;
  final int waterMl;
  final int waterGoalMl;
  final double waterProgress;
  final bool isRunning;

  const DualProgressDial({
    super.key,
    required this.mode,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.timerProgress,
    required this.waterMl,
    required this.waterGoalMl,
    required this.waterProgress,
    required this.isRunning,
  });

  @override
  State<DualProgressDial> createState() => _DualProgressDialState();
}

class _DualProgressDialState extends State<DualProgressDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const double dialSize = 270.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color trackColor = isDark ? const Color(0xFF262B35) : const Color(0xFFE6E0D5);
    final Color progressColor = isDark
        ? (widget.mode == SessionMode.focus ? AppTheme.nordicFocusArc : AppTheme.nordicBreak)
        : (widget.mode == SessionMode.focus ? AppTheme.ceramicFocusArc : AppTheme.ceramicTerracotta);

    final Color waterColorPrimary = isDark ? AppTheme.nordicWater : AppTheme.ceramicWater;
    final Color waterColorSecondary = isDark ? const Color(0xFF4F6B84) : const Color(0xFF5E7E69);

    final int waterPct = (widget.waterProgress * 100).toInt();

    return Center(
      child: SizedBox(
        width: dialSize,
        height: dialSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner liquid reservoir (no neon)
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: ClipOval(
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(dialSize - 44, dialSize - 44),
                      painter: LiquidWavePainter(
                        wavePhase: _waveController.value * 2 * math.pi,
                        fillPercentage: widget.waterProgress,
                        primaryColor: waterColorPrimary,
                        secondaryColor: waterColorSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Outer Radial Ring Painter (Clean matte line)
            CustomPaint(
              size: const Size(dialSize, dialSize),
              painter: _MatteTimerPainter(
                progress: widget.timerProgress,
                trackColor: trackColor,
                progressColor: progressColor,
                strokeWidth: 6.0,
              ),
            ),

            // Center Content (Time, Mode badge, Water counter)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mode Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF222630) : const Color(0xFFEAE5DB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    widget.mode.shortName.toUpperCase(),
                    style: TextStyle(
                      color: isDark ? AppTheme.nordicTextSecondary : AppTheme.ceramicTextSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Countdown Timer Text
                Text(
                  _formatTime(widget.remainingSeconds),
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                    color: isDark ? AppTheme.nordicTextPrimary : AppTheme.ceramicTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Water Subtitle
                Text(
                  '💧 ${widget.waterMl} / ${widget.waterGoalMl} ml ($waterPct%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.nordicTextSecondary : AppTheme.ceramicTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatteTimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _MatteTimerPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Background track
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.001) return;

    // Active progress arc
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _MatteTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
