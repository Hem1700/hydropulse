import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/timer_session.dart';
import '../models/hydration_entry.dart';
import '../models/ambient_sound.dart';
import '../models/live_radio.dart';
import '../models/spotify_playlist.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;
  final AudioService _audio;
  final NotificationService _notifications;

  Timer? _ticker;

  // Timer properties
  SessionMode _sessionMode = SessionMode.focus;
  bool _isRunning = false;
  int _remainingSeconds = 25 * 60;
  int _totalSessionSeconds = 25 * 60;
  int _completedCycles = 0;
  int _todayFocusMinutes = 0;

  // Hydration properties
  int _todayWaterMl = 0;
  int _dailyWaterGoalMl = 2000;
  List<HydrationEntry> _entries = [];

  // Streak properties
  int _currentStreak = 0;
  int _bestStreak = 0;

  // Ambient sound properties
  AmbientSoundType _ambientType = AmbientSoundType.rain;
  double _ambientVolume = 0.6;
  final bool _autoPlayAmbient = true;

  // Spotify properties
  String _customSpotifyUrl = '';
  SpotifyFocusPlaylist? _activeSpotifyPlaylist;

  // Live radio properties
  LiveRadioStation? _activeRadioStation;
  final bool _autoStartLofi = true;

  // Completion trigger for UI (shows celebratory dialog)
  bool _shouldShowSipPrompt = false;

  // Getters
  SessionMode get sessionMode => _sessionMode;
  bool get isRunning => _isRunning;
  int get remainingSeconds => _remainingSeconds;
  int get totalSessionSeconds => _totalSessionSeconds;
  double get timerProgress => _totalSessionSeconds > 0
      ? 1.0 - (_remainingSeconds / _totalSessionSeconds)
      : 0.0;

  int get completedCycles => _completedCycles;
  int get todayFocusMinutes => _todayFocusMinutes;

  int get todayWaterMl => _todayWaterMl;
  int get dailyWaterGoalMl => _dailyWaterGoalMl;
  double get waterProgress =>
      _dailyWaterGoalMl > 0 ? (_todayWaterMl / _dailyWaterGoalMl).clamp(0.0, 1.5) : 0.0;
  List<HydrationEntry> get entries => List.unmodifiable(_entries);

  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;

  AmbientSoundType get ambientType => _ambientType;
  double get ambientVolume => _ambientVolume;
  bool get isAmbientPlaying => _audio.isAmbientPlaying;
  bool get autoPlayAmbient => _autoPlayAmbient;

  String get customSpotifyUrl => _customSpotifyUrl;
  SpotifyFocusPlaylist? get activeSpotifyPlaylist => _activeSpotifyPlaylist;

  LiveRadioStation? get activeRadioStation => _activeRadioStation;
  bool get isRadioPlaying => _audio.isRadioPlaying;
  bool get autoStartLofi => _autoStartLofi;

  bool get shouldShowSipPrompt => _shouldShowSipPrompt;

  AppState({
    required StorageService storage,
    required AudioService audio,
    required NotificationService notifications,
  })  : _storage = storage,
        _audio = audio,
        _notifications = notifications {
    _loadState();
  }

  void _loadState() {
    _storage.checkAndHandleDayRollover(onStreakUpdated: (s) {
      _currentStreak = s;
    });

    _todayWaterMl = _storage.getTodayWater();
    _dailyWaterGoalMl = _storage.getDailyWaterGoal();
    _todayFocusMinutes = _storage.getTodayFocusMinutes();
    _completedCycles = _storage.getTodayCompletedSessions();
    _entries = _storage.getHydrationEntries();
    _currentStreak = _storage.getStreak();
    _bestStreak = _storage.getBestStreak();

    _ambientType = _storage.getAmbientSoundType();
    _ambientVolume = _storage.getAmbientVolume();
    _customSpotifyUrl = _storage.getCustomSpotifyUrl();

    // Default focus session
    final focusMins = _storage.getFocusDurationMinutes();
    _totalSessionSeconds = focusMins * 60;
    _remainingSeconds = _totalSessionSeconds;

    notifyListeners();

    // Auto-start lofi radio in background
    if (_autoStartLofi) {
      Future.delayed(const Duration(milliseconds: 800), () {
        final station = LiveRadioStation.defaultStation;
        _activeRadioStation = station;
        _audio.playRadio(station);
        notifyListeners();
      });
    }
  }

  // Timer controls
  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _triggerHaptic(HapticFeedbackType.light);

    // Auto-play ambient sound if in focus mode
    if (_sessionMode == SessionMode.focus &&
        _ambientType != AmbientSoundType.none &&
        !_audio.isAmbientPlaying) {
      _audio.playAmbient(_ambientType, volume: _ambientVolume);
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onSessionComplete();
      }
    });

    notifyListeners();
  }

  void pauseTimer() {
    if (!_isRunning) return;

    _ticker?.cancel();
    _isRunning = false;
    _triggerHaptic(HapticFeedbackType.light);

    if (_audio.isAmbientPlaying) {
      _audio.pauseAmbient();
    }

    notifyListeners();
  }

  void resetTimer() {
    _ticker?.cancel();
    _isRunning = false;
    _triggerHaptic(HapticFeedbackType.medium);

    if (_audio.isAmbientPlaying) {
      _audio.stopAmbient();
    }

    _applyModeDuration(_sessionMode);
    notifyListeners();
  }

  void skipToNextMode() {
    _ticker?.cancel();
    _isRunning = false;
    if (_audio.isAmbientPlaying) {
      _audio.stopAmbient();
    }

    if (_sessionMode == SessionMode.focus) {
      _transitionToBreak();
    } else {
      _transitionToFocus();
    }
  }

  void setSessionMode(SessionMode mode) {
    if (_sessionMode == mode) return;
    _ticker?.cancel();
    _isRunning = false;
    _sessionMode = mode;
    _applyModeDuration(mode);
    notifyListeners();
  }

  void _applyModeDuration(SessionMode mode) {
    int minutes;
    switch (mode) {
      case SessionMode.focus:
        minutes = _storage.getFocusDurationMinutes();
        break;
      case SessionMode.shortBreak:
        minutes = _storage.getShortBreakMinutes();
        break;
      case SessionMode.longBreak:
        minutes = _storage.getLongBreakMinutes();
        break;
    }
    _totalSessionSeconds = minutes * 60;
    _remainingSeconds = _totalSessionSeconds;
  }

  Future<void> _onSessionComplete() async {
    _ticker?.cancel();
    _isRunning = false;

    // Play singing bowl chime
    if (_storage.getSoundEffectsEnabled()) {
      _audio.playBowlChimeSfx();
    }

    // Heavy tactile vibration
    _triggerHaptic(HapticFeedbackType.heavy);

    if (_sessionMode == SessionMode.focus) {
      // Completed a focus sprint!
      final focusMins = _storage.getFocusDurationMinutes();
      _todayFocusMinutes += focusMins;
      _completedCycles += 1;
      await _storage.setTodayFocusMinutes(_todayFocusMinutes);
      await _storage.setTodayCompletedSessions(_completedCycles);

      // Notification
      _notifications.showSessionCompleteNotification(
        title: 'Focus Sprint Complete! 🎯',
        body: 'Great work! Take a mindful sip of water and rest your eyes.',
      );

      // Prompt UI to celebrate and hydrate
      _shouldShowSipPrompt = true;

      // Transition to break
      _transitionToBreak();
    } else {
      // Completed a rest break
      _notifications.showSessionCompleteNotification(
        title: 'Rest Ended ⚡️',
        body: 'Ready to dive back into deep focus?',
      );
      _transitionToFocus();
    }

    notifyListeners();
  }

  void _transitionToBreak() {
    if (_completedCycles > 0 && _completedCycles % 4 == 0) {
      _sessionMode = SessionMode.longBreak;
    } else {
      _sessionMode = SessionMode.shortBreak;
    }
    _applyModeDuration(_sessionMode);

    // Stop ambient sound during break
    _audio.stopAmbient();
  }

  void _transitionToFocus() {
    _sessionMode = SessionMode.focus;
    _applyModeDuration(_sessionMode);
  }

  void dismissSipPrompt() {
    _shouldShowSipPrompt = false;
    notifyListeners();
  }

  // Hydration Actions
  Future<void> addWater(int amountMl) async {
    if (amountMl <= 0) return;

    _todayWaterMl += amountMl;
    await _storage.setTodayWater(_todayWaterMl);

    // Play water drop SFX
    if (_storage.getSoundEffectsEnabled()) {
      _audio.playWaterDropSfx();
    }

    _triggerHaptic(HapticFeedbackType.selection);

    final entry = HydrationEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
    _entries.insert(0, entry);
    await _storage.saveHydrationEntries(_entries);

    // Check streak qualification
    if (_todayWaterMl >= _dailyWaterGoalMl && _currentStreak == 0) {
      _currentStreak = 1;
      await _storage.setStreak(_currentStreak);
    }

    notifyListeners();
  }

  Future<void> removeWaterEntry(String id) async {
    final idx = _entries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final removed = _entries.removeAt(idx);
      _todayWaterMl = (_todayWaterMl - removed.amountMl).clamp(0, 99999);
      await _storage.setTodayWater(_todayWaterMl);
      await _storage.saveHydrationEntries(_entries);
      notifyListeners();
    }
  }

  // Ambient Sound Controls
  Future<void> setAmbientSound(AmbientSoundType type) async {
    _ambientType = type;
    await _storage.setAmbientSoundType(type);

    if (type == AmbientSoundType.none) {
      await _audio.stopAmbient();
    } else {
      await _audio.playAmbient(type, volume: _ambientVolume);
    }
    notifyListeners();
  }

  Future<void> setAmbientVolume(double volume) async {
    _ambientVolume = volume;
    await _storage.setAmbientVolume(volume);
    await _audio.setAmbientVolume(volume);
    notifyListeners();
  }

  Future<void> toggleAmbientPlayback() async {
    if (_audio.isAmbientPlaying) {
      await _audio.stopAmbient();
    } else if (_ambientType != AmbientSoundType.none) {
      await _audio.playAmbient(_ambientType, volume: _ambientVolume);
    }
    notifyListeners();
  }

  // Live Radio Controls
  Future<void> setRadioStation(LiveRadioStation station) async {
    _activeRadioStation = station;
    await _audio.playRadio(station);
    notifyListeners();
  }

  Future<void> toggleRadio() async {
    if (_audio.isRadioPlaying) {
      await _audio.stopRadio();
    } else if (_activeRadioStation != null) {
      await _audio.playRadio(_activeRadioStation!);
    } else {
      final station = LiveRadioStation.defaultStation;
      _activeRadioStation = station;
      await _audio.playRadio(station);
    }
    notifyListeners();
  }

  Future<void> setRadioVolume(double volume) async {
    await _audio.setRadioVolume(volume);
    notifyListeners();
  }

  Future<void> stopRadio() async {
    await _audio.stopRadio();
    notifyListeners();
  }

  // Spotify Focus Integration
  Future<bool> launchSpotifyPlaylist(SpotifyFocusPlaylist playlist) async {
    _activeSpotifyPlaylist = playlist;
    _triggerHaptic(HapticFeedbackType.light);

    // Stop internal audio so user can enjoy Spotify
    if (_audio.isAmbientPlaying) {
      await _audio.stopAmbient();
    }
    if (_audio.isRadioPlaying) {
      await _audio.stopRadio();
    }

    final nativeUri = Uri.parse(playlist.spotifyUri);
    final webUri = Uri.parse(playlist.webUrl);

    try {
      final canLaunchNative = await canLaunchUrl(nativeUri);
      if (canLaunchNative) {
        final launched = await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
        notifyListeners();
        return launched;
      }
    } catch (_) {}

    final launchedWeb = await launchUrl(webUri, mode: LaunchMode.externalApplication);
    notifyListeners();
    return launchedWeb;
  }

  Future<bool> launchCustomSpotifyUrl(String rawUrl) async {
    final cleanUrl = rawUrl.trim();
    if (cleanUrl.isEmpty) return false;

    _customSpotifyUrl = cleanUrl;
    await _storage.setCustomSpotifyUrl(cleanUrl);

    if (_audio.isAmbientPlaying) {
      await _audio.stopAmbient();
    }

    final uri = Uri.tryParse(cleanUrl);
    if (uri != null) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  // Settings updates
  Future<void> updateSettings({
    required int focusMins,
    required int shortBreakMins,
    required int longBreakMins,
    required int waterGoalMl,
    required bool soundEnabled,
    required bool hapticsEnabled,
  }) async {
    await _storage.setFocusDurationMinutes(focusMins);
    await _storage.setShortBreakMinutes(shortBreakMins);
    await _storage.setLongBreakMinutes(longBreakMins);
    await _storage.setDailyWaterGoal(waterGoalMl);
    await _storage.setSoundEffectsEnabled(soundEnabled);
    await _storage.setHapticsEnabled(hapticsEnabled);

    _dailyWaterGoalMl = waterGoalMl;
    if (!_isRunning) {
      _applyModeDuration(_sessionMode);
    }
    notifyListeners();
  }

  void _triggerHaptic(HapticFeedbackType type) {
    if (!_storage.getHapticsEnabled()) return;
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _audio.dispose();
    super.dispose();
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}
