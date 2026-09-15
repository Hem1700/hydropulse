class SpotifyFocusPlaylist {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String spotifyUri;
  final String webUrl;
  final bool isFeatured;

  const SpotifyFocusPlaylist({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.spotifyUri,
    required this.webUrl,
    this.isFeatured = false,
  });

  static const List<SpotifyFocusPlaylist> curated = [
    SpotifyFocusPlaylist(
      id: 'lofi_girl',
      title: 'Lofi Girl — Beats to Relax/Study to',
      subtitle: 'The iconic 24/7 lo-fi hip hop study & focus stream',
      icon: '☕',
      spotifyUri: 'spotify:playlist/0vvXsWCC9xrXsKd4FyS8kM',
      webUrl: 'https://open.spotify.com/playlist/0vvXsWCC9xrXsKd4FyS8kM',
      isFeatured: true,
    ),
    SpotifyFocusPlaylist(
      id: 'deep_focus',
      title: 'Deep Focus',
      subtitle: 'Atmospheric ambient & post-rock flow',
      icon: '🧠',
      spotifyUri: 'spotify:playlist/37i9dQZF1DWZeKCadgRdKQ',
      webUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
    ),
    SpotifyFocusPlaylist(
      id: 'peaceful_piano',
      title: 'Peaceful Piano',
      subtitle: 'Gentle acoustic & minimalist piano',
      icon: '🎹',
      spotifyUri: 'spotify:playlist/37i9dQZF1DX4sWSpwq3LiO',
      webUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
    ),
    SpotifyFocusPlaylist(
      id: 'chillwave',
      title: 'Chillwave & Synth',
      subtitle: 'Retro atmospheric synthesizer tracks',
      icon: '🌆',
      spotifyUri: 'spotify:playlist/37i9dQZF1DXdLEN7aqioXM',
      webUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXdLEN7aqioXM',
    ),
    SpotifyFocusPlaylist(
      id: 'nature_soundscape',
      title: 'Nature & Rainfall',
      subtitle: 'Gentle showers, mountain streams & ocean surf',
      icon: '🍃',
      spotifyUri: 'spotify:playlist/37i9dQZF1DX8ymr6UES72q',
      webUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX8ymr6UES72q',
    ),
  ];
}
