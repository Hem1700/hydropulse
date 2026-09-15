import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_session.dart';
import '../models/ambient_sound.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/dual_progress_dial.dart';
import '../widgets/quick_hydration_bar.dart';
import '../widgets/streak_badge.dart';
import '../widgets/sip_break_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if a completed focus session should trigger the Sip dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.shouldShowSipPrompt) {
        appState.dismissSipPrompt();
        SipBreakDialog.show(
          context,
          onSipAndBreak: () {
            appState.addWater(250);
            appState.startTimer();
          },
          onJustBreak: () {
            appState.startTimer();
          },
        );
      }
    });

    final sound = AmbientSound.all.firstWhere(
      (s) => s.type == appState.ambientType,
      orElse: () => AmbientSound.all.first,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Streak and Audio Pill
            StreakBadge(
              streakDays: appState.currentStreak,
              focusMinutes: appState.todayFocusMinutes,
              currentSoundIcon: appState.activeSpotifyPlaylist != null
                  ? appState.activeSpotifyPlaylist!.icon
                  : sound.icon,
              isPlayingSound: appState.isAmbientPlaying,
            ),

            const SizedBox(height: 8),

            // Mode Selector Pill (Focus / Short Break / Long Break)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _ModeTab(
                      title: 'Focus',
                      icon: Icons.bolt_rounded,
                      isSelected: appState.sessionMode == SessionMode.focus,
                      activeColor: AppTheme.primaryAqua,
                      onTap: () => appState.setSessionMode(SessionMode.focus),
                    ),
                    _ModeTab(
                      title: 'Short Break',
                      icon: Icons.local_drink_rounded,
                      isSelected: appState.sessionMode == SessionMode.shortBreak,
                      activeColor: AppTheme.breakGreen,
                      onTap: () => appState.setSessionMode(SessionMode.shortBreak),
                    ),
                    _ModeTab(
                      title: 'Long Break',
                      icon: Icons.bedtime_rounded,
                      isSelected: appState.sessionMode == SessionMode.longBreak,
                      activeColor: AppTheme.softAmber,
                      onTap: () => appState.setSessionMode(SessionMode.longBreak),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Center Dual Progress Dial
            DualProgressDial(
              mode: appState.sessionMode,
              remainingSeconds: appState.remainingSeconds,
              totalSeconds: appState.totalSessionSeconds,
              timerProgress: appState.timerProgress,
              waterMl: appState.todayWaterMl,
              waterGoalMl: appState.dailyWaterGoalMl,
              waterProgress: appState.waterProgress,
              isRunning: appState.isRunning,
            ),

            const SizedBox(height: 16),

            // Guidance text
            Text(
              appState.sessionMode.guidance,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),

            const Spacer(),

            // Primary Timer Controls (Reset, Play/Pause, Skip)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset button
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF19243A) : const Color(0xFFE2E8F0),
                      padding: const EdgeInsets.all(14),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 24),
                    onPressed: () => appState.resetTimer(),
                  ),
                  const SizedBox(width: 24),

                  // Main Play/Pause Button
                  GestureDetector(
                    onTap: () {
                      if (appState.isRunning) {
                        appState.pauseTimer();
                      } else {
                        appState.startTimer();
                      }
                    },
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryAqua,
                            appState.sessionMode == SessionMode.focus
                                ? AppTheme.focusPurple
                                : AppTheme.breakGreen,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryAqua.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        appState.isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Skip to next cycle button
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF19243A) : const Color(0xFFE2E8F0),
                      padding: const EdgeInsets.all(14),
                    ),
                    icon: const Icon(Icons.skip_next_rounded, size: 24),
                    onPressed: () => appState.skipToNextMode(),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Quick Hydration Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: QuickHydrationBar(
                onAddWater: (ml) => appState.addWater(ml),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ModeTab({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.22 : 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor.withValues(alpha: 0.6) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? activeColor
                    : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
