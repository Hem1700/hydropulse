import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hydration_entry.dart';
import '../models/ambient_sound.dart';

class StorageService {
  static const String _keyLastActiveDate = 'last_active_date';
  static const String _keyTodayWater = 'today_water';
  static const String _keyTodayFocusMinutes = 'today_focus_minutes';
  static const String _keyTodayCompletedSessions = 'today_completed_sessions';
  static const String _keyHydrationEntries = 'hydration_entries';
  static const String _keyStreak = 'current_streak';
  static const String _keyBestStreak = 'best_streak';

  // Settings keys
  static const String _keyFocusMinutes = 'setting_focus_minutes';
  static const String _keyShortBreakMinutes = 'setting_short_break_minutes';
  static const String _keyLongBreakMinutes = 'setting_long_break_minutes';
  static const String _keyDailyWaterGoal = 'setting_daily_water_goal';
  static const String _keySoundEffects = 'setting_sound_effects';
  static const String _keyHaptics = 'setting_haptics';
  static const String _keyAmbientType = 'setting_ambient_type';
  static const String _keyAmbientVolume = 'setting_ambient_volume';
  static const String _keyCustomSpotify = 'setting_custom_spotify';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void checkAndHandleDayRollover({
    required Function(int streak) onStreakUpdated,
  }) {
    final todayStr = _todayDateString();
    final lastActive = _prefs.getString(_keyLastActiveDate);

    if (lastActive == null) {
      _prefs.setString(_keyLastActiveDate, todayStr);
      return;
    }

    if (lastActive != todayStr) {
      final lastDate = DateTime.tryParse(lastActive);
      final now = DateTime.now();
      final differenceInDays = lastDate != null
          ? DateTime(now.year, now.month, now.day)
              .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
              .inDays
          : 999;

      int currentStreak = getStreak();
      final int yesterdayWater = getTodayWater();
      final int waterGoal = getDailyWaterGoal();

      if (differenceInDays == 1) {
        // Yesterday: Did they achieve the goal?
        if (yesterdayWater >= (waterGoal * 0.75)) {
          currentStreak += 1;
        }
      } else {
        // Missed a day
        currentStreak = 0;
      }

      setStreak(currentStreak);
      onStreakUpdated(currentStreak);

      // Reset daily counts for the new day
      _prefs.setInt(_keyTodayWater, 0);
      _prefs.setInt(_keyTodayFocusMinutes, 0);
      _prefs.setInt(_keyTodayCompletedSessions, 0);
      _prefs.setStringList(_keyHydrationEntries, []);
      _prefs.setString(_keyLastActiveDate, todayStr);
    }
  }

  // Daily Stats
  int getTodayWater() => _prefs.getInt(_keyTodayWater) ?? 0;
  Future<void> setTodayWater(int ml) => _prefs.setInt(_keyTodayWater, ml);

  int getTodayFocusMinutes() => _prefs.getInt(_keyTodayFocusMinutes) ?? 0;
  Future<void> setTodayFocusMinutes(int mins) => _prefs.setInt(_keyTodayFocusMinutes, mins);

  int getTodayCompletedSessions() => _prefs.getInt(_keyTodayCompletedSessions) ?? 0;
  Future<void> setTodayCompletedSessions(int count) => _prefs.setInt(_keyTodayCompletedSessions, count);

  List<HydrationEntry> getHydrationEntries() {
    final rawList = _prefs.getStringList(_keyHydrationEntries) ?? [];
    return rawList.map((str) {
      final map = jsonDecode(str) as Map<String, dynamic>;
      return HydrationEntry.fromJson(map);
    }).toList();
  }

  Future<void> saveHydrationEntries(List<HydrationEntry> entries) {
    final rawList = entries.map((e) => jsonEncode(e.toJson())).toList();
    return _prefs.setStringList(_keyHydrationEntries, rawList);
  }

  int getStreak() => _prefs.getInt(_keyStreak) ?? 0;
  Future<void> setStreak(int streak) async {
    await _prefs.setInt(_keyStreak, streak);
    final best = getBestStreak();
    if (streak > best) {
      await _prefs.setInt(_keyBestStreak, streak);
    }
  }

  int getBestStreak() => _prefs.getInt(_keyBestStreak) ?? 0;

  // Settings
  int getFocusDurationMinutes() => _prefs.getInt(_keyFocusMinutes) ?? 25;
  Future<void> setFocusDurationMinutes(int mins) => _prefs.setInt(_keyFocusMinutes, mins);

  int getShortBreakMinutes() => _prefs.getInt(_keyShortBreakMinutes) ?? 5;
  Future<void> setShortBreakMinutes(int mins) => _prefs.setInt(_keyShortBreakMinutes, mins);

  int getLongBreakMinutes() => _prefs.getInt(_keyLongBreakMinutes) ?? 15;
  Future<void> setLongBreakMinutes(int mins) => _prefs.setInt(_keyLongBreakMinutes, mins);

  int getDailyWaterGoal() => _prefs.getInt(_keyDailyWaterGoal) ?? 2000;
  Future<void> setDailyWaterGoal(int ml) => _prefs.setInt(_keyDailyWaterGoal, ml);

  bool getSoundEffectsEnabled() => _prefs.getBool(_keySoundEffects) ?? true;
  Future<void> setSoundEffectsEnabled(bool enabled) => _prefs.setBool(_keySoundEffects, enabled);

  bool getHapticsEnabled() => _prefs.getBool(_keyHaptics) ?? true;
  Future<void> setHapticsEnabled(bool enabled) => _prefs.setBool(_keyHaptics, enabled);

  AmbientSoundType getAmbientSoundType() {
    final index = _prefs.getInt(_keyAmbientType);
    if (index == null || index < 0 || index >= AmbientSoundType.values.length) {
      return AmbientSoundType.rain;
    }
    return AmbientSoundType.values[index];
  }

  Future<void> setAmbientSoundType(AmbientSoundType type) =>
      _prefs.setInt(_keyAmbientType, type.index);

  double getAmbientVolume() => _prefs.getDouble(_keyAmbientVolume) ?? 0.6;
  Future<void> setAmbientVolume(double volume) =>
      _prefs.setDouble(_keyAmbientVolume, volume);

  String getCustomSpotifyUrl() => _prefs.getString(_keyCustomSpotify) ?? '';
  Future<void> setCustomSpotifyUrl(String url) =>
      _prefs.setString(_keyCustomSpotify, url);
}
