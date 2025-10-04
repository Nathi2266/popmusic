import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../models/artist.dart';
import '../widgets/attribute_bar.dart';

class ArtistDetailScreen extends StatelessWidget {
  final String artistId;

  const ArtistDetailScreen({
    super.key,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final artist = gameState.npcs.firstWhere(
          (a) => a.id == artistId,
          orElse: () => gameState.npcs.first,
        );

        final player = gameState.player;
        final relationship = player?.relationships[artistId] ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(artist.name),
            backgroundColor: const Color(0xFF16213e),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Artist Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: _getGenreColor(artist.primaryGenre),
                          child: Text(
                            artist.name[0],
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          artist.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getGenreName(artist.primaryGenre),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Popularity',
                        value: '${artist.attributes.popularity.toInt()}',
                        icon: Icons.star,
                        color: Colors.amber,
                      ),
                      _StatColumn(
                        label: 'Fans',
                        value: '${artist.fanCount}',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      _StatColumn(
                        label: 'Songs',
                        value: '${artist.releasedSongs.length}',
                        icon: Icons.music_note,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Relationship
                  if (player != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2a3e),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Relationship',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getRelationshipText(relationship),
                            style: TextStyle(
                              color: _getRelationshipColor(relationship),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Attributes
                  const Text(
                    'ATTRIBUTES',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AttributeBar(
                    label: 'Performance',
                    value: artist.attributes.performance,
                    color: const Color(0xFF2196F3),
                  ),
                  AttributeBar(
                    label: 'Talent',
                    value: artist.attributes.talent,
                    color: const Color(0xFFFF9800),
                  ),
                  AttributeBar(
                    label: 'Charisma',
                    value: artist.attributes.charisma,
                    color: const Color(0xFFFFEB3B),
                  ),
                  AttributeBar(
                    label: 'Creativity',
                    value: artist.attributes.creativity,
                    color: const Color(0xFFE91E63),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  const Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Collaborate action
                      },
                      icon: const Icon(Icons.handshake),
                      label: const Text('Collaborate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe94560),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        gameState.networkWithArtist(artist);
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Network'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2a2a3e),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getGenreName(Genre genre) {
    switch (genre) {
      case Genre.pop:
        return 'Pop';
      case Genre.rock:
        return 'Rock';
      case Genre.hiphop:
        return 'Hip Hop';
      case Genre.rnb:
        return 'R&B';
      case Genre.electronic:
        return 'Electronic';
      case Genre.indie:
        return 'Indie';
      case Genre.country:
        return 'Country';
      case Genre.jazz:
        return 'Jazz';
      case Genre.latin:
        return 'Latin';
      case Genre.kpop:
        return 'K-Pop';
    }
  }

  Color _getGenreColor(Genre genre) {
    switch (genre) {
      case Genre.pop:
        return const Color(0xFFe94560);
      case Genre.rock:
        return const Color(0xFF8B4513);
      case Genre.hiphop:
        return const Color(0xFF9C27B0);
      case Genre.rnb:
        return const Color(0xFFFF6B9D);
      case Genre.electronic:
        return const Color(0xFF00BCD4);
      case Genre.indie:
        return const Color(0xFF8BC34A);
      case Genre.country:
        return const Color(0xFFFF9800);
      case Genre.jazz:
        return const Color(0xFF673AB7);
      case Genre.latin:
        return const Color(0xFFF44336);
      case Genre.kpop:
        return const Color(0xFFE91E63);
    }
  }

  String _getRelationshipText(int value) {
    if (value >= 80) return 'Best Friends';
    if (value >= 50) return 'Friends';
    if (value >= 20) return 'Acquaintances';
    if (value >= -20) return 'Neutral';
    if (value >= -50) return 'Dislike';
    return 'Rivals';
  }

  Color _getRelationshipColor(int value) {
    if (value >= 50) return const Color(0xFF4CAF50);
    if (value >= 0) return const Color(0xFF2196F3);
    return const Color(0xFFF44336);
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
