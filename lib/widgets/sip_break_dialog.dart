import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SipBreakDialog extends StatelessWidget {
  final VoidCallback onSipAndBreak;
  final VoidCallback onJustBreak;

  const SipBreakDialog({
    super.key,
    required this.onSipAndBreak,
    required this.onJustBreak,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onSipAndBreak,
    required VoidCallback onJustBreak,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SipBreakDialog(
        onSipAndBreak: () {
          Navigator.pop(ctx);
          onSipAndBreak();
        },
        onJustBreak: () {
          Navigator.pop(ctx);
          onJustBreak();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF101827) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing droplet icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryAqua.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppTheme.primaryAqua.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: const Text('💧', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 18),

            const Text(
              'Focus Sprint Complete!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              'You worked with deep intention. Now hydrate your brain, stretch your shoulders, and rest your eyes.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Button 1: Sip + Break
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAqua,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.water_drop_rounded, size: 20),
                label: const Text(
                  'Drink +250ml & Start Break',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                onPressed: onSipAndBreak,
              ),
            ),
            const SizedBox(height: 10),

            // Button 2: Just Break
            TextButton(
              onPressed: onJustBreak,
              child: Text(
                'Skip drink, just start break',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
