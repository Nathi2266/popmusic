import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import 'create_song_screen.dart';
import '../models/song.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final player = gameState.player;
        final playerSongs = gameState.worldSongs // Changed from allSongs to worldSongs
            .where((song) => song.artistId == player?.id)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Music'),
            backgroundColor: const Color(0xFF16213e),
          ),
          body: Column(
            children: [
              // Create Music Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateSongScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 28),
                    label: const Text(
                      'CREATE NEW SONG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe94560),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
              ),

              // Songs List
              Expanded(
                child: playerSongs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 80,
                              color: Colors.white24,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No songs yet',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create your first hit!',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: playerSongs.length,
                        itemBuilder: (context, index) {
                          final song = playerSongs[index];
                          return _SongCard(song: song);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SongCard extends StatelessWidget {
  final Song song;

  const _SongCard({required this.song});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2a2a3e),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFe94560),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Weeks: ${song.weeksSinceRelease} • Weekly: ${song.weeklyListeners.toStringAsFixed(0)} listeners',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.show_chart,
                          size: 16,
                          color: Colors.lightGreenAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${song.popularityFactor.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.lightGreenAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Streams: ${song.totalStreams.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (song.viralFactor.clamp(0.0, 100.0) / 100), // Use viralFactor
              backgroundColor: const Color(0xFF1a1a2e),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFe94560),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Viral Factor: ${song.viralFactor.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
