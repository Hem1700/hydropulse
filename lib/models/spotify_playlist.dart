class SpotifyFocusPlaylist {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String spotifyUri;
  final String webUrl;
  final bool isCustom;

  const SpotifyFocusPlaylist({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.spotifyUri,
    required this.webUrl,
    this.isCustom = false,
  });

  static const List<SpotifyFocusPlaylist> curated = [
    SpotifyFocusPlaylist(
      id: 'deep_focus',
      title: 'Deep Focus',
      subtitle: 'Atmospheric ambient & post-rock flow',
      icon: '🧠',
      spotifyUri: 'spotify:playlist/37i9dQZF1DWZeKCadgRdKQ',
      webUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
    ),
    SpotifyFocusPlaylist(
      id: 'lofi_beats',
      title: 'Lo-Fi Beats',
      subtitle: 'Chill study instrumental beats',
      icon: '☕',
      spotifyUri: 'spotify:playlist/37i9dQZF1DXdLEN7aqioXM',
      webUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXdLEN7aqioXM',
    ),
    SpotifyFocusPlaylist(
      id: 'peaceful_piano',
      title: 'Peaceful Piano',
      subtitle: 'Gentle classical & minimalist piano',
      icon: '🎹',
      spotifyUri: 'spotify:playlist/37i9dQZF1DX4sWSpwq3LiO',
      webUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
    ),
    SpotifyFocusPlaylist(
      id: 'synthwave_chill',
      title: 'Chillwave & Synth',
      subtitle: 'Retro atmospheric synthesizer tracks',
      icon: '🌆',
      spotifyUri: 'spotify:playlist/37i9dQZF1DXdLEN7aqioXM',
      webUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXdLEN7aqioXM',
    ),
    SpotifyFocusPlaylist(
      id: 'nature_soundscape',
      title: 'Nature Focus',
      subtitle: 'Thunderstorms, gentle streams & sea waves',
      icon: '🍃',
      spotifyUri: 'spotify:playlist/37i9dQZF1DX8ymr6UES72q',
      webUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX8ymr6UES72q',
    ),
  ];
}
