import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/ambient_sound.dart';

class AudioService {
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isAmbientPlaying = false;
  AmbientSoundType _currentAmbientType = AmbientSoundType.none;
  double _currentVolume = 0.6;

  bool get isAmbientPlaying => _isAmbientPlaying;
  AmbientSoundType get currentAmbientType => _currentAmbientType;
  double get currentVolume => _currentVolume;

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
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
    );
    AudioPlayer.global.setAudioContext(context);
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
  }

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
      await _ambientPlayer.stop();
      await _ambientPlayer.setVolume(_currentVolume);
      // audioplayers Source.asset uses the path relative to assets/
      final assetClean = sound.assetPath.replaceFirst('assets/', '');
      await _ambientPlayer.play(AssetSource(assetClean));
      _isAmbientPlaying = true;
      _currentAmbientType = type;
    } catch (e) {
      // Fallback gracefully
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

  Future<void> playWaterDropSfx() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(0.85);
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
    _sfxPlayer.dispose();
  }
}
