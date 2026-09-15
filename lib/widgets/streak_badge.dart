import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'soundscape_sheet.dart';

class StreakBadge extends StatelessWidget {
  final int streakDays;
  final int focusMinutes;
  final String currentSoundIcon;
  final bool isPlayingSound;

  const StreakBadge({
    super.key,
    required this.streakDays,
    required this.focusMinutes,
    required this.currentSoundIcon,
    required this.isPlayingSound,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Streak Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                const Text('🔥 ', style: TextStyle(fontSize: 14)),
                Text(
                  '$streakDays ${streakDays == 1 ? 'Day' : 'Days'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: streakDays > 0 ? AppTheme.softAmber : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•  ⏱️ ${focusMinutes}m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Audio / Spotify Quick Button
          GestureDetector(
            onTap: () => SoundscapeSheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isPlayingSound
                    ? AppTheme.primaryAqua.withValues(alpha: isDark ? 0.2 : 0.15)
                    : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPlayingSound
                      ? AppTheme.primaryAqua.withValues(alpha: 0.5)
                      : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                ),
              ),
              child: Row(
                children: [
                  Text(currentSoundIcon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    isPlayingSound ? 'Playing' : 'Audio',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPlayingSound
                          ? AppTheme.primaryAqua
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: isPlayingSound
                        ? AppTheme.primaryAqua
                        : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
