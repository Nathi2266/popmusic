import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../services/achievement_service.dart';
// Removed Artist import as it's no longer directly used here.
// import '../models/artist.dart';
// Removed LabelTier and ArtistAttributes imports
// import '../models/artist_attributes.dart';
// import '../models/label_tier.dart';
import '../screens/award_detail_screen.dart'; // Added import for AwardDetailScreen
import '../screens/achievements_screen.dart';
import '../widgets/empty_state.dart';

class CareerScreen extends StatelessWidget {
  const CareerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final player = gameState.player;
        
        if (player == null) {
          return const Scaffold(
            body: Center(
              child: Text('No player data'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Career'),
            backgroundColor: const Color(0xFF16213e),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Career Overview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent, // Generic color
                        Colors.blueAccent.withAlpha((255 * 0.6).round()), // Generic color
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unsigned', // Player starts unsigned, label tier is not in Artist model
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ignore: prefer_const_constructors
                      const Text(
                        'Career Level',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        // Removed weeksSinceDebut from Artist model
                        '${(player.attributes['weeksSinceDebut'] ?? 0).toInt()} weeks in the industry',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Removed Label Progression section
                // const Text(
                //   'LABEL PROGRESSION',
                //   style: TextStyle(
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //     letterSpacing: 2,
                //   ),
                // ),
                // const SizedBox(height: 16),
                // _LabelTierCard(
                //   tier: LabelTier.unsigned,
                //   isUnlocked: true,
                //   isCurrent: player.labelTier == LabelTier.unsigned,
                //   requirements: 'Starting tier',
                // ),
                // _LabelTierCard(
                //   tier: LabelTier.indie,
                //   isUnlocked: player.attributes.popularity >= 25,
                //   isCurrent: player.labelTier == LabelTier.indie,
                //   requirements: '25 Popularity, 10 Songs',
                //   onUpgrade: player.attributes.popularity >= 25 && 
                //              player.releasedSongs.length >= 10 &&
                //              player.labelTier == LabelTier.unsigned
                //       ? () => _upgradeLabelTier(context, gameState, LabelTier.indie)
                //       : null,
                // ),
                // _LabelTierCard(
                //   tier: LabelTier.major,
                //   isUnlocked: player.attributes.popularity >= 60,
                //   isCurrent: player.labelTier == LabelTier.major,
                //   requirements: '60 Popularity, 50K Fans',
                //   onUpgrade: player.attributes.popularity >= 60 && 
                //              player.fanCount >= 50000 &&
                //              player.labelTier == LabelTier.indie
                //       ? () => _upgradeLabelTier(context, gameState, LabelTier.major)
                //       : null,
                // ),
                // _LabelTierCard(
                //   tier: LabelTier.superstar,
                //   isUnlocked: player.attributes.popularity >= 85,
                //   isCurrent: player.labelTier == LabelTier.superstar,
                //   requirements: '85 Popularity, 500K Fans, 5 Awards',
                //   onUpgrade: player.attributes.popularity >= 85 && 
                //              player.fanCount >= 500000 &&
                //              player.awards.length >= 5 &&
                //              player.labelTier == LabelTier.major
                //       ? () => _upgradeLabelTier(context, gameState, LabelTier.superstar)
                //       : null,
                // ),
                const SizedBox(height: 24),

                // Achievements Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ACHIEVEMENTS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AchievementsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                      label: const Text('View All', style: TextStyle(color: Color(0xFFFFD700))),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<AchievementService>(
                  builder: (context, achievementService, child) {
                    final unlocked = achievementService.getUnlockedAchievements();
                    final recent = unlocked.take(3).toList();
                    
                    if (recent.isEmpty) {
                      return const EmptyState(
                        icon: Icons.emoji_events,
                        title: 'No achievements yet',
                        subtitle: 'Complete actions to unlock achievements!',
                        iconColor: Color(0xFFFFD700),
                      );
                    }
                    
                    return Column(
                      children: recent.map((achievement) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2a2a3e),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                achievement.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      achievement.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      achievement.description,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Awards
                const Text(
                  'AWARDS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                (player.attributes['awards'] as List<String>?)?.isEmpty ?? true
                    ? const EmptyState(
                        icon: Icons.emoji_events,
                        title: 'No awards yet',
                        subtitle: 'Keep creating hits and performing to earn recognition!',
                        iconColor: Color(0xFFFFD700),
                      )
                    : Column(
                        children: (player.attributes['awards'] as List<String>)
                            .map((award) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2a2a3e),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Color(0xFFFFD700),
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    award,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 24),

                // Career Stats
                const Text(
                  'CAREER STATISTICS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a3e),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _StatRow(
                        label: 'Total Songs Released',
                        value: '${gameState.worldSongs.where((s) => s.artistId == player.id).length}',
                        icon: Icons.music_note,
                      ),
                      const Divider(color: Colors.white24),
                      _StatRow(
                        label: 'Total Albums',
                        value: '${(player.attributes['releasedAlbums'] as List<String>?)?.length ?? 0}',
                        icon: Icons.album,
                      ),
                      const Divider(color: Colors.white24),
                      _StatRow(
                        label: 'Total Fans',
                        value: '${gameState.playerFanCount}',
                        icon: Icons.people,
                      ),
                      const Divider(color: Colors.white24),
                      _StatRow(
                        label: 'Career Earnings',
                        value: '\$${gameState.playerMoney.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                      ),
                      const Divider(color: Colors.white24),
                      _StatRow(
                        label: 'Awards Won',
                        value: '${player.awardsWon.length}',
                        icon: Icons.emoji_events,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AwardDetailScreen(awards: player.awardsWon),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Removed _upgradeLabelTier, _getLabelName, _getLabelColor
  // void _upgradeLabelTier( ... ) { ... }
  // String _getLabelName(LabelTier tier) { ... }
}

// Removed _LabelTierCard class
// class _LabelTierCard extends StatelessWidget { ... }

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap; // Added onTap callback

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap, // Initialize onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Assign onTap to InkWell
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFe94560), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFe94560),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
