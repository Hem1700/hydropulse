/// Live streaming lofi / ambient radio stations
class LiveRadioStation {
  final String id;
  final String name;
  final String genre;
  final String icon;
  final String description;
  final String streamUrl;
  final bool isDefault;

  const LiveRadioStation({
    required this.id,
    required this.name,
    required this.genre,
    required this.icon,
    required this.description,
    required this.streamUrl,
    this.isDefault = false,
  });

  static const List<LiveRadioStation> all = [
    LiveRadioStation(
      id: 'nightwave',
      name: 'Nightwave Lo-Fi',
      genre: 'Lo-Fi Hip Hop',
      icon: '🌙',
      description: 'Dreamy beats to relax and focus',
      streamUrl: 'https://radio.plaza.one/mp3',
      isDefault: true,
    ),
    LiveRadioStation(
      id: 'groovesalad',
      name: 'Groove Salad',
      genre: 'Ambient / Downtempo',
      icon: '🌿',
      description: 'A nicely chilled plate of ambient grooves',
      streamUrl: 'https://ice1.somafm.com/groovesalad-128-mp3',
    ),
    LiveRadioStation(
      id: 'dronezone',
      name: 'Drone Zone',
      genre: 'Deep Ambient',
      icon: '🪐',
      description: 'Served best late-night with headphones',
      streamUrl: 'https://ice1.somafm.com/dronezone-128-mp3',
    ),
    LiveRadioStation(
      id: 'lush',
      name: 'Lush',
      genre: 'Chillout',
      icon: '🌸',
      description: 'Sensuous and mellow female vocals',
      streamUrl: 'https://ice1.somafm.com/lush-128-mp3',
    ),
  ];

  static LiveRadioStation get defaultStation =>
      all.firstWhere((s) => s.isDefault, orElse: () => all.first);
}
