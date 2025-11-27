import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../widgets/attribute_bar.dart';
import '../widgets/stat_card.dart';
import 'performance_screen.dart';
import '../models/song.dart'; // Added import for Song model
import 'weekly_events_and_proceed_button.dart';
import 'charts_screen.dart'; // Import the new ChartsScreen
import '../widgets/error_widget.dart';
import '../widgets/xp_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final player = gameState.player; // Assuming player is still accessible, but its structure has changed.
        
        if (player == null) {
          return const Scaffold(
            body: CustomErrorWidget(
              message: 'No player data',
              details: 'Please start a new game to begin playing.',
              icon: Icons.person_off,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(player.name),
            backgroundColor: const Color(0xFF16213e),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            ),
            actions: [
              Expanded( // Wrap Padding in Expanded
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text(
                      'Week ${gameState.weekOfMonth}, Month ${gameState.month}, ${gameState.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const ProceedWeekButton(),
            ],
          ),
          drawer: Drawer(
            backgroundColor: const Color(0xFF1a1a2e), // Set a consistent background color
            child: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight, // Status bar + AppBar height
                  decoration: const BoxDecoration(
                    color: Color(0xFF16213e),
                  ),
                  child: const SizedBox.shrink(), // Empty child
                ),
                // Other drawer items can go here
                ListTile(
                  leading: const Icon(Icons.show_chart, color: Colors.white70),
                  title: const Text('Charts', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChartsScreen()));
                  },
                ),
                const Spacer(), // Pushes the exit button to the bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit Game'),
                    onPressed: () {
                      // Implement exit game logic here
                      // For example, navigate to main menu or close the app
                      Navigator.of(context).popUntil((route) => route.isFirst); // Example: Pop all routes to main menu
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50), // Make button full width
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level and XP
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a3e),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: XpBar(
                      playerLevel: gameState.getPlayerLevel(),
                      showLevel: true,
                      showXpText: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Money',
                          value: '\$${gameState.playerMoney.toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Fans',
                          value: '${gameState.playerFanCount}',
                          icon: Icons.people,
                          color: const Color(0xFFe94560),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // ignore: prefer_const_constructors
                      Expanded(
                        child: const StatCard(
                          title: 'Label',
                          value: 'Unsigned', // Player starts unsigned
                          icon: Icons.business,
                          // ignore: unnecessary_const
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Songs',
                          value: '${gameState.worldSongs.where((s) => s.artistId == player.id).length}',
                          icon: Icons.music_note,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Display Top 3 Songs
                  const Text(
                    'TOP 3 SONGS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250, // Fixed height to prevent overflow for a few entries
                    child: _buildTopSongsList(gameState.getTopSongs(3), context),
                  ),

                  const SizedBox(height: 24),

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
                    value: player.attributes['popularity'] ?? 0,
                    color: const Color(0xFFe94560),
                  ),
                  AttributeBar(
                    label: 'Reputation',
                    value: player.attributes['reputation'] ?? 0,
                    color: const Color(0xFF4CAF50),
                  ),
                  AttributeBar(
                    label: 'Performance',
                    value: player.attributes['performance'] ?? 0,
                    color: const Color(0xFF2196F3),
                  ),
                  AttributeBar(
                    label: 'Talent',
                    value: player.attributes['talent'] ?? 0,
                    color: const Color(0xFFFF9800),
                  ),
                  AttributeBar(
                    label: 'Production',
                    value: player.attributes['production'] ?? 0,
                    color: const Color(0xFF9C27B0),
                  ),
                  AttributeBar(
                    label: 'Songwriting',
                    value: player.attributes['songwriting'] ?? 0,
                    color: const Color(0xFF00BCD4),
                  ),
                  AttributeBar(
                    label: 'Charisma',
                    value: player.attributes['charisma'] ?? 0,
                    color: const Color(0xFFFFEB3B),
                  ),
                  AttributeBar(
                    label: 'Marketing',
                    value: player.attributes['marketing'] ?? 0,
                    color: const Color(0xFF8BC34A),
                  ),
                  AttributeBar(
                    label: 'Networking',
                    value: player.attributes['networking'] ?? 0,
                    color: const Color(0xFF03A9F4),
                  ),
                  AttributeBar(
                    label: 'Creativity',
                    value: player.attributes['creativity'] ?? 0,
                    color: const Color(0xFFE91E63),
                  ),
                  AttributeBar(
                    label: 'Discipline',
                    value: player.attributes['discipline'] ?? 0,
                    color: const Color(0xFF607D8B),
                  ),
                  AttributeBar(
                    label: 'Stamina',
                    value: player.attributes['stamina'] ?? 0,
                    color: const Color(0xFFFF5722),
                  ),
                  AttributeBar(
                    label: 'Controversy',
                    value: player.attributes['controversy'] ?? 0,
                    color: const Color(0xFFF44336),
                  ),
                  AttributeBar(
                    label: 'Wealth',
                    value: player.attributes['wealth'] ?? 0,
                    color: const Color(0xFFFFD700),
                  ),
                  AttributeBar(
                    label: 'Influence',
                    value: player.attributes['influence'] ?? 0,
                    color: const Color(0xFF673AB7),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ActionButton(
                        label: 'Create Music',
                        icon: Icons.music_note,
                        onPressed: () {
                          // Navigate to music creation
                        },
                      ),
                      _ActionButton(
                        label: 'Perform',
                        icon: Icons.mic,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PerformanceScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        label: 'Network',
                        icon: Icons.people,
                        onPressed: () {
                          // Navigate to networking
                        },
                      ),
                      _ActionButton(
                        label: 'Train',
                        icon: Icons.fitness_center,
                        onPressed: () {
                          // Navigate to training
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopSongsList(List<Song> songs, BuildContext context) {
    if (songs.isEmpty) {
      return const Text(
        'No songs on the charts yet.',
        style: TextStyle(color: Colors.white70),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final artist = Provider.of<GameStateService>(context, listen: false).getArtistById(song.artistId);
        return ListTile(
          leading: CircleAvatar(child: Text('#${index + 1}')),
          title: Text(song.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text('${artist?.name ?? 'Unknown Artist'} - ${song.weeklyListeners.toStringAsFixed(0)} listeners',
              style: const TextStyle(color: Colors.white70)),
          trailing: Text('${song.totalStreams.toStringAsFixed(0)} streams', style: const TextStyle(color: Colors.white70)),
        );
      },
    );
  }
}

// Remove _getLabelName as LabelTier is no longer in Artist model
// String _getLabelName(LabelTier tier) {
//   switch (tier) {
//     case LabelTier.unsigned:
//       return 'Unsigned';
//     case LabelTier.indie:
//       return 'Indie';
//     case LabelTier.major:
//       return 'Major';
//     case LabelTier.superstar:
//       return 'Superstar';
//   }
// }

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2a2a3e),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
