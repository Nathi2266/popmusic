import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../services/achievement_service.dart';
import '../models/label_tier.dart';
import '../screens/award_detail_screen.dart';
import '../screens/achievements_screen.dart';
import '../widgets/empty_state.dart';
import '../utils/toast_service.dart';

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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(player.labelTier.colorValue),
                        Color(player.labelTier.colorValue).withAlpha((255 * 0.6).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.labelTier.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Weekly income \$${player.labelTier.weeklyIncome.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
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

                const Text(
                  'LABEL PROGRESSION',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                _LabelTierCard(
                  tier: LabelTier.unsigned,
                  isUnlocked: true,
                  isCurrent: player.labelTier == LabelTier.unsigned,
                  requirements: LabelTier.unsigned.requirementsText,
                ),
                _LabelTierCard(
                  tier: LabelTier.indie,
                  isUnlocked: player.labelTier.index >= LabelTier.indie.index ||
                      gameState.canUpgradeLabelTier(LabelTier.indie),
                  isCurrent: player.labelTier == LabelTier.indie,
                  requirements: LabelTier.indie.requirementsText,
                  onUpgrade: gameState.canUpgradeLabelTier(LabelTier.indie)
                      ? () => _tryUpgrade(context, gameState, LabelTier.indie)
                      : null,
                ),
                _LabelTierCard(
                  tier: LabelTier.major,
                  isUnlocked: player.labelTier.index >= LabelTier.major.index ||
                      gameState.canUpgradeLabelTier(LabelTier.major),
                  isCurrent: player.labelTier == LabelTier.major,
                  requirements: LabelTier.major.requirementsText,
                  onUpgrade: gameState.canUpgradeLabelTier(LabelTier.major)
                      ? () => _tryUpgrade(context, gameState, LabelTier.major)
                      : null,
                ),
                _LabelTierCard(
                  tier: LabelTier.superstar,
                  isUnlocked: player.labelTier.index >= LabelTier.superstar.index ||
                      gameState.canUpgradeLabelTier(LabelTier.superstar),
                  isCurrent: player.labelTier == LabelTier.superstar,
                  requirements: LabelTier.superstar.requirementsText,
                  onUpgrade: gameState.canUpgradeLabelTier(LabelTier.superstar)
                      ? () => _tryUpgrade(context, gameState, LabelTier.superstar)
                      : null,
                ),
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

  void _tryUpgrade(
    BuildContext context,
    GameStateService gameState,
    LabelTier tier,
  ) {
    final ok = gameState.upgradeLabelTier(tier);
    if (ok) {
      ToastService().showSuccess('Welcome to ${tier.displayName}!');
    } else {
      ToastService().showError('Requirements not met for ${tier.displayName}');
    }
  }
}

class _LabelTierCard extends StatelessWidget {
  final LabelTier tier;
  final bool isUnlocked;
  final bool isCurrent;
  final String requirements;
  final VoidCallback? onUpgrade;

  const _LabelTierCard({
    required this.tier,
    required this.isUnlocked,
    required this.isCurrent,
    required this.requirements,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(tier.colorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? color : Colors.white24,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCurrent
                ? Icons.star
                : isUnlocked
                    ? Icons.lock_open
                    : Icons.lock,
            color: isUnlocked ? color : Colors.white38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.displayName,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  requirements,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '\$${tier.weeklyIncome.toStringAsFixed(0)}/week',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Chip(
              label: const Text('Current'),
              backgroundColor: color.withAlpha(80),
              labelStyle: const TextStyle(color: Colors.white),
            )
          else if (onUpgrade != null)
            ElevatedButton(
              onPressed: onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
              ),
              child: const Text('Sign'),
            ),
        ],
      ),
    );
  }
}

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
