enum AmbientSoundType {
  none,
  rain,
  stream,
  brownNoise,
  lofiPulse,
}

class AmbientSound {
  final AmbientSoundType type;
  final String name;
  final String icon;
  final String assetPath;
  final String description;

  const AmbientSound({
    required this.type,
    required this.name,
    required this.icon,
    required this.assetPath,
    required this.description,
  });

  static const List<AmbientSound> all = [
    AmbientSound(
      type: AmbientSoundType.none,
      name: 'Silent',
      icon: '🔕',
      assetPath: '',
      description: 'Zero ambient audio',
    ),
    AmbientSound(
      type: AmbientSoundType.rain,
      name: 'Gentle Rain',
      icon: '🌧️',
      assetPath: 'assets/audio/rain.wav',
      description: 'Alpha-wave inducing rain patter',
    ),
    AmbientSound(
      type: AmbientSoundType.stream,
      name: 'Forest Stream',
      icon: '🌊',
      assetPath: 'assets/audio/stream.wav',
      description: 'Calm babbling water brook',
    ),
    AmbientSound(
      type: AmbientSoundType.brownNoise,
      name: 'Deep Focus',
      icon: '🪐',
      assetPath: 'assets/audio/brown_noise.wav',
      description: 'Warm low-frequency brown noise',
    ),
    AmbientSound(
      type: AmbientSoundType.lofiPulse,
      name: 'Lo-Fi Pulse',
      icon: '🎵',
      assetPath: 'assets/audio/lofi_pulse.wav',
      description: 'Soft 60 BPM ambient chord pulse',
    ),
  ];
}
