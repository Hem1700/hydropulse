import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ambient_sound.dart';
import '../models/live_radio.dart';
import '../models/spotify_playlist.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SoundscapeSheet extends StatefulWidget {
  const SoundscapeSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SoundscapeSheet(),
    );
  }

  @override
  State<SoundscapeSheet> createState() => _SoundscapeSheetState();
}

class _SoundscapeSheetState extends State<SoundscapeSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _customSpotifyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customSpotifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.nordicWater : AppTheme.ceramicWater;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.nordicBg : AppTheme.ceramicBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header row with live radio status pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Sound & Music',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                if (appState.isRadioPlaying)
                  _LivePill(
                    label: appState.activeRadioStation?.name ?? 'Live Radio',
                    isDark: isDark,
                    accentColor: accentColor,
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab Bar — 3 tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.nordicCard : AppTheme.ceramicCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accentColor,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: isDark ? Colors.white : Colors.white,
                unselectedLabelColor: isDark ? Colors.white60 : AppTheme.ceramicTextSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                tabs: const [
                  Tab(text: '📻 Lo-Fi Radio'),
                  Tab(text: '🌊 Ambient'),
                  Tab(text: '🎧 Spotify'),
                ],
              ),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRadioTab(context, appState, isDark, accentColor),
                _buildAmbientTab(context, appState, isDark, accentColor),
                _buildSpotifyTab(context, appState, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Live Radio ───────────────────────────────────────────────────────

  Widget _buildRadioTab(
    BuildContext context,
    AppState appState,
    bool isDark,
    Color accentColor,
  ) {
    final cardBg = isDark ? AppTheme.nordicCard : AppTheme.ceramicCard;
    final cardSubtle = isDark ? AppTheme.nordicCardSubtle : AppTheme.ceramicCardSubtle;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Now playing banner (if any)
        if (appState.isRadioPlaying && appState.activeRadioStation != null) ...[
          _NowPlayingBanner(
            station: appState.activeRadioStation!,
            isDark: isDark,
            accentColor: accentColor,
            onStop: () => appState.stopRadio(),
          ),
          const SizedBox(height: 16),
        ],

        // Volume control
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Radio Volume',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.nordicTextPrimary : AppTheme.ceramicTextPrimary,
                    ),
                  ),
                  Text(
                    '${(appState.isRadioPlaying ? 55 : 0).toInt()}%',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: 0.55,
                onChanged: (val) => appState.setRadioVolume(val),
                activeColor: accentColor,
                inactiveColor: cardSubtle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'LOFI & CHILL STATIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: isDark ? AppTheme.nordicTextSecondary : AppTheme.ceramicTextSecondary,
          ),
        ),
        const SizedBox(height: 10),

        ...LiveRadioStation.all.map((station) {
          final isActive = appState.activeRadioStation?.id == station.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? accentColor.withValues(alpha: isDark ? 0.18 : 0.14)
                  : cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? accentColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.nordicCardSubtle : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(station.icon, style: const TextStyle(fontSize: 20)),
              ),
              title: Text(
                station.name,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? accentColor
                      : (isDark ? AppTheme.nordicTextPrimary : AppTheme.ceramicTextPrimary),
                ),
              ),
              subtitle: Text(
                station.genre,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.nordicTextSecondary : AppTheme.ceramicTextSecondary,
                ),
              ),
              trailing: isActive
                  ? IconButton(
                      icon: Icon(
                        appState.isRadioPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: accentColor,
                        size: 32,
                      ),
                      onPressed: () => appState.toggleRadio(),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.play_circle_outline_rounded,
                        color: isDark
                            ? AppTheme.nordicTextSecondary
                            : AppTheme.ceramicTextSecondary,
                        size: 32,
                      ),
                      onPressed: () => appState.setRadioStation(station),
                    ),
              onTap: () => appState.setRadioStation(station),
            ),
          );
        }),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 14,
                  color: isDark
                      ? AppTheme.nordicTextSecondary
                      : AppTheme.ceramicTextSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Streams require an internet connection. Volume mixer keeps SFX separate.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppTheme.nordicTextSecondary
                        : AppTheme.ceramicTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab 2: Offline Ambient ──────────────────────────────────────────────────

  Widget _buildAmbientTab(
    BuildContext context,
    AppState appState,
    bool isDark,
    Color accentColor,
  ) {
    final cardBg = isDark ? AppTheme.nordicCard : AppTheme.ceramicCard;
    final cardSubtle = isDark ? AppTheme.nordicCardSubtle : AppTheme.ceramicCardSubtle;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Text(
          'OFFLINE SOUNDSCAPES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: isDark ? AppTheme.nordicTextSecondary : AppTheme.ceramicTextSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...AmbientSound.all.map((sound) {
          final isSelected = appState.ambientType == sound.type;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: isDark ? 0.15 : 0.12)
                  : cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? accentColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? cardSubtle : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(sound.icon, style: const TextStyle(fontSize: 20)),
              ),
              title: Text(
                sound.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? accentColor
                      : (isDark
                          ? AppTheme.nordicTextPrimary
                          : AppTheme.ceramicTextPrimary),
                ),
              ),
              subtitle: Text(
                sound.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.nordicTextSecondary
                      : AppTheme.ceramicTextSecondary,
                ),
              ),
              trailing: isSelected && sound.type != AmbientSoundType.none
                  ? IconButton(
                      icon: Icon(
                        appState.isAmbientPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: accentColor,
                        size: 32,
                      ),
                      onPressed: () => appState.toggleAmbientPlayback(),
                    )
                  : (isSelected
                      ? Icon(Icons.check_circle_rounded, color: accentColor)
                      : null),
              onTap: () => appState.setAmbientSound(sound.type),
            ),
          );
        }),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ambient Volume',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.nordicTextPrimary
                          : AppTheme.ceramicTextPrimary,
                    ),
                  ),
                  Text(
                    '${(appState.ambientVolume * 100).toInt()}%',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: appState.ambientVolume,
                onChanged: (val) => appState.setAmbientVolume(val),
                activeColor: accentColor,
                inactiveColor: cardSubtle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab 3: Spotify ──────────────────────────────────────────────────────────

  Widget _buildSpotifyTab(
    BuildContext context,
    AppState appState,
    bool isDark,
  ) {
    final cardBg = isDark ? AppTheme.nordicCard : AppTheme.ceramicCard;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF1DB954).withValues(alpha: 0.35)),
          ),
          child: const Row(
            children: [
              Text('🎵 ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  'Tap a playlist to open it in Spotify. Your hydration timers and water sounds will continue in the background.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'CURATED FOCUS PLAYLISTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: isDark
                ? AppTheme.nordicTextSecondary
                : AppTheme.ceramicTextSecondary,
          ),
        ),
        const SizedBox(height: 10),

        ...SpotifyFocusPlaylist.curated.map((playlist) {
          final isFeatured = playlist.isFeatured;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isFeatured
                  ? const Color(0xFF1DB954).withValues(alpha: isDark ? 0.12 : 0.08)
                  : cardBg,
              borderRadius: BorderRadius.circular(16),
              border: isFeatured
                  ? Border.all(
                      color: const Color(0xFF1DB954).withValues(alpha: 0.4))
                  : null,
            ),
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.nordicCardSubtle : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(playlist.icon, style: const TextStyle(fontSize: 20)),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      playlist.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.nordicTextPrimary
                            : AppTheme.ceramicTextPrimary,
                      ),
                    ),
                  ),
                  if (isFeatured)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'YOUR PICK',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                playlist.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.nordicTextSecondary
                      : AppTheme.ceramicTextSecondary,
                ),
              ),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Open',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () => appState.launchSpotifyPlaylist(playlist),
              ),
            ),
          );
        }),

        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Custom Spotify Playlist',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.nordicTextPrimary
                      : AppTheme.ceramicTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paste any Spotify playlist, album, or track URL:',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.nordicTextSecondary
                      : AppTheme.ceramicTextSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customSpotifyController
                        ..text = appState.customSpotifyUrl,
                      decoration: InputDecoration(
                        hintText: 'https://open.spotify.com/playlist/...',
                        hintStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_customSpotifyController.text.isNotEmpty) {
                        appState.launchCustomSpotifyUrl(
                            _customSpotifyController.text);
                      }
                    },
                    child: const Text('Open'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _LivePill extends StatelessWidget {
  final String label;
  final bool isDark;
  final Color accentColor;

  const _LivePill({
    required this.label,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingBanner extends StatelessWidget {
  final LiveRadioStation station;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onStop;

  const _NowPlayingBanner({
    required this.station,
    required this.isDark,
    required this.accentColor,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.12 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Text(station.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: accentColor,
                  ),
                ),
                Text(
                  station.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.nordicTextPrimary
                        : AppTheme.ceramicTextPrimary,
                  ),
                ),
                Text(
                  station.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.nordicTextSecondary
                        : AppTheme.ceramicTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.stop_circle_rounded, size: 28),
            color: accentColor,
            onPressed: onStop,
          ),
        ],
      ),
    );
  }
}
