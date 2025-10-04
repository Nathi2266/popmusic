import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../models/artist.dart';

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
                        _getLabelColor(player.labelTier),
                        _getLabelColor(player.labelTier).withAlpha((255 * 0.6).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLabelName(player.labelTier),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ignore: prefer_const_constructors
                      Text(
                        'Career Level',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${player.weeksSinceDebut} weeks in the industry',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Label Progression
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
                  requirements: 'Starting tier',
                ),
                _LabelTierCard(
                  tier: LabelTier.indie,
                  isUnlocked: player.attributes.popularity >= 25,
                  isCurrent: player.labelTier == LabelTier.indie,
                  requirements: '25 Popularity, 10 Songs',
                  onUpgrade: player.attributes.popularity >= 25 && 
                             player.releasedSongs.length >= 10 &&
                             player.labelTier == LabelTier.unsigned
                      ? () => _upgradeLabelTier(context, gameState, LabelTier.indie)
                      : null,
                ),
                _LabelTierCard(
                  tier: LabelTier.major,
                  isUnlocked: player.attributes.popularity >= 60,
                  isCurrent: player.labelTier == LabelTier.major,
                  requirements: '60 Popularity, 50K Fans',
                  onUpgrade: player.attributes.popularity >= 60 && 
                             player.fanCount >= 50000 &&
                             player.labelTier == LabelTier.indie
                      ? () => _upgradeLabelTier(context, gameState, LabelTier.major)
                      : null,
                ),
                _LabelTierCard(
                  tier: LabelTier.superstar,
                  isUnlocked: player.attributes.popularity >= 85,
                  isCurrent: player.labelTier == LabelTier.superstar,
                  requirements: '85 Popularity, 500K Fans, 5 Awards',
                  onUpgrade: player.attributes.popularity >= 85 && 
                             player.fanCount >= 500000 &&
                             player.awards.length >= 5 &&
                             player.labelTier == LabelTier.major
                      ? () => _upgradeLabelTier(context, gameState, LabelTier.superstar)
                      : null,
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
                player.awards.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a3e),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 48,
                                color: Colors.white24,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No awards yet',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: player.awards.map((award) {
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
                        value: '${player.releasedSongs.length}',
                        icon: Icons.music_note,
                      ),
                      const Divider(color: Colors.white24),
                      _StatRow(
                        label: 'Total Albums',
                        value: '${player.releasedAlbums.length}',
                        icon: Icons.album,
                      ),
                      const Divider(color: Colors.white24),
                      _StatRow(
                        label: 'Total Fans',
                        value: '${player.fanCount}',
                        icon: Icons.people,
                      ),
                      const Divider(color: Colors.white24),
                      _StatRow(
                        label: 'Career Earnings',
                        value: '\$${player.money}',
                        icon: Icons.attach_money,
                      ),
                      const Divider(color: Colors.white24),
                      _StatRow(
                        label: 'Awards Won',
                        value: '${player.awards.length}',
                        icon: Icons.emoji_events,
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

  void _upgradeLabelTier(
    BuildContext context,
    GameStateService gameState,
    LabelTier newTier,
  ) {
    final player = gameState.player;
    if (player == null) return;

    player.labelTier = newTier;
    gameState.updatePlayerAttribute('influence', 10);
    gameState.updatePlayerAttribute('wealth', 10);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a3e),
        title: Row(
          children: [
            Icon(
              Icons.celebration,
              color: _getLabelColor(newTier),
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Congratulations!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'You\'ve been signed to a ${_getLabelName(newTier)} label!',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('AMAZING!'),
          ),
        ],
      ),
    );
  }

  String _getLabelName(LabelTier tier) {
    switch (tier) {
      case LabelTier.unsigned:
        return 'Unsigned';
      case LabelTier.indie:
        return 'Indie Label';
      case LabelTier.major:
        return 'Major Label';
      case LabelTier.superstar:
        return 'Superstar';
    }
  }

  Color _getLabelColor(LabelTier tier) {
    switch (tier) {
      case LabelTier.unsigned:
        return const Color(0xFF607D8B);
      case LabelTier.indie:
        return const Color(0xFF4CAF50);
      case LabelTier.major:
        return const Color(0xFF2196F3);
      case LabelTier.superstar:
        return const Color(0xFFFFD700);
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? _getLabelColor(tier).withAlpha((255 * 0.2).round())
            : const Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? _getLabelColor(tier)
              : isUnlocked
                  ? Colors.white24
                  : Colors.white12,
          width: isCurrent ? 3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUnlocked ? Icons.check_circle : Icons.lock,
                color: isUnlocked ? _getLabelColor(tier) : Colors.white24,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLabelName(tier),
                      style: TextStyle(
                        color: isUnlocked ? Colors.white : Colors.white38,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      requirements,
                      style: TextStyle(
                        color: isUnlocked ? Colors.white70 : Colors.white24,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getLabelColor(tier),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'CURRENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (onUpgrade != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getLabelColor(tier),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'SIGN CONTRACT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getLabelName(LabelTier tier) {
    switch (tier) {
      case LabelTier.unsigned:
        return 'Unsigned';
      case LabelTier.indie:
        return 'Indie Label';
      case LabelTier.major:
        return 'Major Label';
      case LabelTier.superstar:
        return 'Superstar';
    }
  }

  Color _getLabelColor(LabelTier tier) {
    switch (tier) {
      case LabelTier.unsigned:
        return const Color(0xFF607D8B);
      case LabelTier.indie:
        return const Color(0xFF4CAF50);
      case LabelTier.major:
        return const Color(0xFF2196F3);
      case LabelTier.superstar:
        return const Color(0xFFFFD700);
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
