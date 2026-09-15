import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;

  const SettingsScreen({super.key, required this.storageService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _focusMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;
  late int _dailyWaterGoal;
  late bool _soundEffects;
  late bool _haptics;

  @override
  void initState() {
    super.initState();
    _focusMinutes = widget.storageService.getFocusDurationMinutes();
    _shortBreakMinutes = widget.storageService.getShortBreakMinutes();
    _longBreakMinutes = widget.storageService.getLongBreakMinutes();
    _dailyWaterGoal = widget.storageService.getDailyWaterGoal();
    _soundEffects = widget.storageService.getSoundEffectsEnabled();
    _haptics = widget.storageService.getHapticsEnabled();
  }

  void _save(AppState appState) {
    appState.updateSettings(
      focusMins: _focusMinutes,
      shortBreakMins: _shortBreakMinutes,
      longBreakMins: _longBreakMinutes,
      waterGoalMl: _dailyWaterGoal,
      soundEnabled: _soundEffects,
      hapticsEnabled: _haptics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Section 1: Timer Intervals
          _sectionHeader('TIMER INTERVALS (MINUTES)', isDark),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _sliderRow(
                  label: 'Focus Sprint',
                  value: _focusMinutes.toDouble(),
                  min: 10,
                  max: 60,
                  divisions: 10,
                  displayValue: '$_focusMinutes min',
                  activeColor: AppTheme.primaryAqua,
                  onChanged: (val) {
                    setState(() => _focusMinutes = val.toInt());
                    _save(appState);
                  },
                ),
                const Divider(height: 24),
                _sliderRow(
                  label: 'Short Sip Break',
                  value: _shortBreakMinutes.toDouble(),
                  min: 3,
                  max: 15,
                  divisions: 12,
                  displayValue: '$_shortBreakMinutes min',
                  activeColor: AppTheme.breakGreen,
                  onChanged: (val) {
                    setState(() => _shortBreakMinutes = val.toInt());
                    _save(appState);
                  },
                ),
                const Divider(height: 24),
                _sliderRow(
                  label: 'Long Recovery',
                  value: _longBreakMinutes.toDouble(),
                  min: 10,
                  max: 30,
                  divisions: 4,
                  displayValue: '$_longBreakMinutes min',
                  activeColor: AppTheme.softAmber,
                  onChanged: (val) {
                    setState(() => _longBreakMinutes = val.toInt());
                    _save(appState);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Hydration Target
          _sectionHeader('HYDRATION TARGET', isDark),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daily Water Goal', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '$_dailyWaterGoal ml (~${(_dailyWaterGoal / 1000).toStringAsFixed(1)} L)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryAqua,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _dailyWaterGoal.toDouble(),
                  min: 1000,
                  max: 4000,
                  divisions: 12,
                  activeColor: AppTheme.primaryAqua,
                  onChanged: (val) {
                    setState(() => _dailyWaterGoal = val.toInt());
                    _save(appState);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: Audio & Haptic Feedback
          _sectionHeader('AUDIO & HAPTIC FEEDBACK', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sound Effects & Chimes', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Singing bowl chime and water droplet sounds', style: TextStyle(fontSize: 12)),
                  value: _soundEffects,
                  activeThumbColor: AppTheme.primaryAqua,
                  onChanged: (val) {
                    setState(() => _soundEffects = val);
                    _save(appState);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Haptic Vibration Feedback', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Tactile clicks and pulse alerts', style: TextStyle(fontSize: 12)),
                  value: _haptics,
                  activeThumbColor: AppTheme.primaryAqua,
                  onChanged: (val) {
                    setState(() => _haptics = val);
                    _save(appState);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 4: Privacy & App Store Details
          _sectionHeader('ABOUT & PRIVACY', isDark),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🛡️ ', style: TextStyle(fontSize: 18)),
                    Text(
                      '100% Privacy Guaranteed',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'HydroPulse operates entirely offline on your device. Your focus sessions, water logs, and habits are never uploaded to any remote server.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('App Version', style: TextStyle(fontSize: 13)),
                    Text(
                      '1.0.0 (Build 1)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              displayValue,
              style: TextStyle(fontWeight: FontWeight.w700, color: activeColor),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: activeColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
