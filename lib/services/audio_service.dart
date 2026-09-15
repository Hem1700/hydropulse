import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/ambient_sound.dart';
import '../models/live_radio.dart';

class AudioService {
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _radioPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isAmbientPlaying = false;
  bool _isRadioPlaying = false;
  AmbientSoundType _currentAmbientType = AmbientSoundType.none;
  LiveRadioStation? _currentStation;
  double _currentVolume = 0.6;
  double _radioVolume = 0.55;

  bool get isAmbientPlaying => _isAmbientPlaying;
  bool get isRadioPlaying => _isRadioPlaying;
  AmbientSoundType get currentAmbientType => _currentAmbientType;
  LiveRadioStation? get currentStation => _currentStation;
  double get currentVolume => _currentVolume;
  double get radioVolume => _radioVolume;

  AudioService() {
    _initAudioContext();
  }

  void _initAudioContext() {
    if (kIsWeb) {
      _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      return;
    }
    // Configure iOS AudioSession to mix with others (like Spotify or Apple Music)
    final context = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
          AVAudioSessionOptions.defaultToSpeaker,
        },
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    );
    AudioPlayer.global.setAudioContext(context);
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // ── Offline Ambient ─────────────────────────────────────────────────────────

  Future<void> playAmbient(AmbientSoundType type, {double? volume}) async {
    if (type == AmbientSoundType.none) {
      await stopAmbient();
      _currentAmbientType = AmbientSoundType.none;
      return;
    }

    if (volume != null) {
      _currentVolume = volume;
    }

    final sound = AmbientSound.all.firstWhere(
      (s) => s.type == type,
      orElse: () => AmbientSound.all.first,
    );

    if (sound.assetPath.isEmpty) {
      await stopAmbient();
      return;
    }

    try {
      // Stop radio if playing offline ambient
      await stopRadio();
      await _ambientPlayer.stop();
      await _ambientPlayer.setVolume(_currentVolume);
      final assetClean = sound.assetPath.replaceFirst('assets/', '');
      await _ambientPlayer.play(AssetSource(assetClean));
      _isAmbientPlaying = true;
      _currentAmbientType = type;
    } catch (e) {
      _isAmbientPlaying = false;
    }
  }

  Future<void> setAmbientVolume(double volume) async {
    _currentVolume = volume.clamp(0.0, 1.0);
    if (_isAmbientPlaying) {
      await _ambientPlayer.setVolume(_currentVolume);
    }
  }

  Future<void> pauseAmbient() async {
    if (_isAmbientPlaying) {
      await _ambientPlayer.pause();
      _isAmbientPlaying = false;
    }
  }

  Future<void> resumeAmbient() async {
    if (!_isAmbientPlaying && _currentAmbientType != AmbientSoundType.none) {
      await playAmbient(_currentAmbientType, volume: _currentVolume);
    }
  }

  Future<void> stopAmbient() async {
    try {
      await _ambientPlayer.stop();
    } catch (_) {}
    _isAmbientPlaying = false;
  }

  // ── Live Radio Streaming ────────────────────────────────────────────────────

  Future<void> playRadio(LiveRadioStation station, {double? volume}) async {
    if (volume != null) {
      _radioVolume = volume.clamp(0.0, 1.0);
    }

    try {
      // Stop offline ambient when playing radio
      await stopAmbient();
      await _radioPlayer.stop();
      await _radioPlayer.setVolume(_radioVolume);
      await _radioPlayer.play(UrlSource(station.streamUrl));
      _isRadioPlaying = true;
      _currentStation = station;
    } catch (e) {
      _isRadioPlaying = false;
      _currentStation = null;
    }
  }

  Future<void> setRadioVolume(double volume) async {
    _radioVolume = volume.clamp(0.0, 1.0);
    if (_isRadioPlaying) {
      await _radioPlayer.setVolume(_radioVolume);
    }
  }

  Future<void> pauseRadio() async {
    if (_isRadioPlaying) {
      try {
        await _radioPlayer.pause();
      } catch (_) {
        await _radioPlayer.stop();
      }
      _isRadioPlaying = false;
    }
  }

  Future<void> resumeRadio() async {
    if (!_isRadioPlaying && _currentStation != null) {
      await playRadio(_currentStation!);
    }
  }

  Future<void> stopRadio() async {
    try {
      await _radioPlayer.stop();
    } catch (_) {}
    _isRadioPlaying = false;
  }

  // ── SFX ────────────────────────────────────────────────────────────────────

  Future<void> playWaterDropSfx() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(0.9);
      await _sfxPlayer.play(AssetSource('audio/water_drop.wav'));
    } catch (_) {}
  }

  Future<void> playBowlChimeSfx() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(1.0);
      await _sfxPlayer.play(AssetSource('audio/bowl_chime.wav'));
    } catch (_) {}
  }

  void dispose() {
    _ambientPlayer.dispose();
    _radioPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
