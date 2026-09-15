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
    const double dialSize = 280.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color trackColor;
    Color progressStartColor;
    Color progressEndColor;

    switch (widget.mode) {
      case SessionMode.focus:
        trackColor = isDark ? const Color(0xFF162138) : const Color(0xFFE2E8F0);
        progressStartColor = AppTheme.primaryAqua;
        progressEndColor = AppTheme.focusPurple;
        break;
      case SessionMode.shortBreak:
        trackColor = isDark ? const Color(0xFF132822) : const Color(0xFFD1FAE5);
        progressStartColor = AppTheme.breakGreen;
        progressEndColor = AppTheme.primaryAqua;
        break;
      case SessionMode.longBreak:
        trackColor = isDark ? const Color(0xFF262015) : const Color(0xFFFEF3C7);
        progressStartColor = AppTheme.softAmber;
        progressEndColor = AppTheme.breakGreen;
        break;
    }

    final int waterPct = (widget.waterProgress * 100).toInt();

    return Center(
      child: SizedBox(
        width: dialSize,
        height: dialSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient outer glow when running
            if (widget.isRunning)
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: dialSize - 10,
                height: dialSize - 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: progressStartColor.withValues(alpha: 0.18),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),

            // Inner liquid reservoir
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ClipOval(
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(dialSize - 36, dialSize - 36),
                      painter: LiquidWavePainter(
                        wavePhase: _waveController.value * 2 * math.pi,
                        fillPercentage: widget.waterProgress,
                        primaryColor: AppTheme.primaryAqua,
                        secondaryColor: AppTheme.deepWater,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Outer Radial Ring Painter (Focus Progress)
            CustomPaint(
              size: const Size(dialSize, dialSize),
              painter: _RadialTimerPainter(
                progress: widget.timerProgress,
                trackColor: trackColor,
                startColor: progressStartColor,
                endColor: progressEndColor,
                strokeWidth: 12.0,
              ),
            ),

            // Center Content (Time, Mode badge, Water counter)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mode Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: progressStartColor.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.mode == SessionMode.focus
                            ? Icons.self_improvement_rounded
                            : Icons.local_drink_rounded,
                        size: 14,
                        color: progressStartColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.mode.shortName.toUpperCase(),
                        style: TextStyle(
                          color: progressStartColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Countdown Timer Text
                Text(
                  _formatTime(widget.remainingSeconds),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    shadows: isDark
                        ? [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.7),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),

                // Water Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '💧 ',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${widget.waterMl} / ${widget.waterGoalMl} ml ($waterPct%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.primaryAqua : AppTheme.deepWater,
                        ),
                      ),
                    ],
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

class _RadialTimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color startColor;
  final Color endColor;
  final double strokeWidth;

  _RadialTimerPainter({
    required this.progress,
    required this.trackColor,
    required this.startColor,
    required this.endColor,
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
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [startColor, endColor, startColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);

    // Outer edge indicator dot
    final double angle = -math.pi / 2 + sweepAngle;
    final double dotX = center.dx + radius * math.cos(angle);
    final double dotY = center.dy + radius * math.sin(angle);

    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RadialTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor;
  }
}
