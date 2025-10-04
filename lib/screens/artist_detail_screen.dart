import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../models/song.dart'; // Added Song import
import '../widgets/attribute_bar.dart';
// Removed Genre import
// import '../models/genre.dart';

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
        final artist = gameState.getArtistById(artistId); // Use getArtistById

        if (artist == null) {
          return Scaffold( // Removed const here
            appBar: AppBar(title: const Text('Artist Not Found')),
            body: const Center(child: Text('Artist data not available')),
          );
        }
        
        // Removed player and relationship logic
        // final player = gameState.player;
        // final relationship = player?.relationships[artistId] ?? 0;

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
                          backgroundColor: Colors.blueAccent, // Generic color since genre is removed
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
                        // Removed genre display
                        // Text(
                        //   _getGenreName(artist.primaryGenre),
                        //   style: const TextStyle(
                        //     fontSize: 18,
                        //     color: Colors.white70,
                        //   ),
                        // ),
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
                        value: '${(artist.attributes['popularity'] ?? 0).toInt()}',
                        icon: Icons.star,
                        color: Colors.amber,
                      ),
                      _StatColumn(
                        label: 'Fans',
                        value: '${(artist.attributes['fan_connection'] ?? 0 * 100).toInt()}',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      _StatColumn(
                        label: 'Songs',
                        value: '${gameState.worldSongs.where((s) => s.artistId == artist.id).length}',
                        icon: Icons.music_note,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Removed Relationship section
                  // if (player != null) ...[
                  //   Container(
                  //     padding: const EdgeInsets.all(16),
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xFF2a2a3e),
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         const Text(
                  //           'Relationship',
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 16,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //         Text(
                  //           _getRelationshipText(relationship),
                  //           style: TextStyle(
                  //             color: _getRelationshipColor(relationship),
                  //             fontSize: 16,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  //   const SizedBox(height: 24),
                  // ],

                  // Artist Songs
                  const Text(
                    'SONGS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildArtistSongsList(gameState.worldSongs.where((s) => s.artistId == artist.id).toList(), gameState),
                  const SizedBox(height: 24),

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
                    label: 'Popularity',
                    value: artist.attributes['popularity'] ?? 0,
                    color: const Color(0xFFe94560),
                  ),
                  AttributeBar(
                    label: 'Reputation',
                    value: artist.attributes['reputation'] ?? 0,
                    color: const Color(0xFF4CAF50),
                  ),
                  AttributeBar(
                    label: 'Performance',
                    value: artist.attributes['performance'] ?? 0,
                    color: const Color(0xFF2196F3),
                  ),
                  AttributeBar(
                    label: 'Talent',
                    value: artist.attributes['talent'] ?? 0,
                    color: const Color(0xFFFF9800),
                  ),
                  AttributeBar(
                    label: 'Production',
                    value: artist.attributes['production'] ?? 0,
                    color: const Color(0xFF9C27B0),
                  ),
                  AttributeBar(
                    label: 'Songwriting',
                    value: artist.attributes['songwriting'] ?? 0,
                    color: const Color(0xFF00BCD4),
                  ),
                  AttributeBar(
                    label: 'Charisma',
                    value: artist.attributes['charisma'] ?? 0,
                    color: const Color(0xFFFFEB3B),
                  ),
                  AttributeBar(
                    label: 'Marketing',
                    value: artist.attributes['marketing'] ?? 0,
                    color: const Color(0xFF8BC34A),
                  ),
                  AttributeBar(
                    label: 'Networking',
                    value: artist.attributes['networking'] ?? 0,
                    color: const Color(0xFF03A9F4),
                  ),
                  AttributeBar(
                    label: 'Creativity',
                    value: artist.attributes['creativity'] ?? 0,
                    color: const Color(0xFFE91E63),
                  ),
                  AttributeBar(
                    label: 'Discipline',
                    value: artist.attributes['discipline'] ?? 0,
                    color: const Color(0xFF607D8B),
                  ),
                  AttributeBar(
                    label: 'Stamina',
                    value: artist.attributes['stamina'] ?? 0,
                    color: const Color(0xFFFF5722),
                  ),
                  AttributeBar(
                    label: 'Controversy',
                    value: artist.attributes['controversy'] ?? 0,
                    color: const Color(0xFFF44336),
                  ),
                  AttributeBar(
                    label: 'Wealth',
                    value: artist.attributes['wealth'] ?? 0,
                    color: const Color(0xFFFFD700),
                  ),
                  AttributeBar(
                    label: 'Influence',
                    value: artist.attributes['influence'] ?? 0,
                    color: const Color(0xFF673AB7),
                  ),
                  AttributeBar(
                    label: 'Happiness',
                    value: artist.attributes['happiness'] ?? 0,
                    color: const Color(0xFF00C853),
                  ),
                  AttributeBar(
                    label: 'Fan Connection',
                    value: artist.attributes['fan_connection'] ?? 0,
                    color: const Color(0xFFE040FB),
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
                        // gameState.networkWithArtist(artist); // Removed as relationships are no longer tracked in this way
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Networking with ${artist.name} (action not fully implemented)')),
                        );
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

  // Removed _getGenreName, _getGenreColor, _getRelationshipText, _getRelationshipColor
  // String _getGenreName(Genre genre) { ... }
  // Color _getGenreColor(Genre genre) { ... }
  // String _getRelationshipText(int value) { ... }
  // Color _getRelationshipColor(int value) { ... }

  Widget _buildArtistSongsList(List<Song> songs, GameStateService gameState) {
    if (songs.isEmpty) {
      return const Text(
        'No songs released yet.',
        style: TextStyle(color: Colors.white70),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          title: Text(song.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text('Weekly Listeners: ${song.weeklyListeners.toStringAsFixed(0)} • Total Streams: ${song.totalStreams.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70)),
          trailing: Text('Weeks: ${song.weeksSinceRelease}', style: const TextStyle(color: Colors.white70)),
        );
      },
    );
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
