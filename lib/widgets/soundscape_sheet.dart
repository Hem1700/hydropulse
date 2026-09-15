import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ambient_sound.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1626) : Colors.white,
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Focus Audio & Music',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF192237) : const Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.primaryAqua,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: '🌊 Offline Ambient'),
                  Tab(text: '🎧 Spotify Playlists'),
                ],
              ),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Offline Ambient Soundscapes
                _buildAmbientTab(context, appState, isDark),

                // TAB 2: Spotify Focus Integration
                _buildSpotifyTab(context, appState, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientTab(BuildContext context, AppState appState, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Text(
          'SELECT SOUNDSCAPE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...AmbientSound.all.map((sound) {
          final isSelected = appState.ambientType == sound.type;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryAqua.withValues(alpha: isDark ? 0.15 : 0.12)
                  : (isDark ? const Color(0xFF141D30) : const Color(0xFFF7FAFC)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppTheme.primaryAqua : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C273E) : Colors.white,
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
                      ? AppTheme.primaryAqua
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              subtitle: Text(
                sound.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              trailing: isSelected && sound.type != AmbientSoundType.none
                  ? IconButton(
                      icon: Icon(
                        appState.isAmbientPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: AppTheme.primaryAqua,
                        size: 32,
                      ),
                      onPressed: () => appState.toggleAmbientPlayback(),
                    )
                  : (isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryAqua)
                      : null),
              onTap: () => appState.setAmbientSound(sound.type),
            ),
          );
        }),

        const SizedBox(height: 16),
        // Volume Control
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141D30) : const Color(0xFFF7FAFC),
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
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    '${(appState.ambientVolume * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppTheme.primaryAqua,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: appState.ambientVolume,
                onChanged: (val) => appState.setAmbientVolume(val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpotifyTab(BuildContext context, AppState appState, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Apple Music/Spotify Notice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: isDark ? 0.15 : 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1DB954).withValues(alpha: 0.4)),
          ),
          child: const Row(
            children: [
              Text('🟢 ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  'Launch any playlist in Spotify. HydroPulse timer chimes and water logs will mix smoothly without interrupting your music.',
                  style: TextStyle(fontSize: 12, height: 1.35),
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
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 10),

        ...SpotifyFocusPlaylist.curated.map((playlist) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141D30) : const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C273E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(playlist.icon, style: const TextStyle(fontSize: 20)),
              ),
              title: Text(
                playlist.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                playlist.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Play', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () => appState.launchSpotifyPlaylist(playlist),
              ),
            ),
          );
        }),

        const SizedBox(height: 14),
        // Custom Spotify URL Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141D30) : const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Custom Spotify Playlist',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Paste any Spotify playlist, album, or track URL:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customSpotifyController..text = appState.customSpotifyUrl,
                      decoration: InputDecoration(
                        hintText: 'https://open.spotify.com/playlist/...',
                        hintStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_customSpotifyController.text.isNotEmpty) {
                        appState.launchCustomSpotifyUrl(_customSpotifyController.text);
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
