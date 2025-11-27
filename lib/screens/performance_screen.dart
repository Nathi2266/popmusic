import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../services/achievement_service.dart';
import '../services/challenge_service.dart';
import '../models/venue.dart';
import '../models/artist.dart';
import '../models/challenge.dart';
import 'performance_minigame_screen.dart';
import '../utils/toast_service.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

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

        final availableVenues = VenueData.venues
            .where((v) => v.popularityRequired <= (player.attributes['popularity'] ?? 0))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Performances'),
            backgroundColor: const Color(0xFF16213e),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Player Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a3e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Performance',
                          value: '${(player.attributes['performance'] ?? 0).toInt()}',
                          icon: Icons.mic,
                          color: const Color(0xFF2196F3),
                        ),
                        _StatItem(
                          label: 'Stamina',
                          value: '${(player.attributes['stamina'] ?? 0).toInt()}',
                          icon: Icons.battery_full,
                          color: const Color(0xFF4CAF50),
                        ),
                        _StatItem(
                          label: 'Charisma',
                          value: '${(player.attributes['charisma'] ?? 0).toInt()}',
                          icon: Icons.star,
                          color: const Color(0xFFFFEB3B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'AVAILABLE VENUES',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              ...availableVenues.map((venue) => _VenueCard(
                venue: venue,
                player: player,
                onPerform: () async {
                  if ((player.attributes['stamina'] ?? 0) < 20) {
                    ToastService().showError('Not enough stamina!');
                    return;
                  }

                  final score = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerformanceMinigameScreen(
                        venue: venue,
                      ),
                    ),
                  );

                  if (score != null) {
                    if (!context.mounted) return;
                    _processPerformance(context, gameState, venue, score);
                    
                    // Check performance achievements
                    final achievementService = Provider.of<AchievementService>(context, listen: false);
                    achievementService.incrementProgress('first_performance');
                    final performanceCount = (gameState.player?.attributes['performanceCount'] ?? 0) + 1;
                    gameState.updatePlayerAttribute('performanceCount', 1);
                    if (performanceCount >= 10) {
                      achievementService.updateProgress('ten_performances', performanceCount.toInt());
                    }
                  }
                },
              )),

              if (availableVenues.length < VenueData.venues.length) ...[
                const SizedBox(height: 24),
                const Text(
                  'LOCKED VENUES',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                ...VenueData.venues
                    .where((v) => v.popularityRequired > (player.attributes['popularity'] ?? 0))
                    .map((venue) => _LockedVenueCard(venue: venue)),
              ],
            ],
          ),
        );
      },
    );
  }

  void _processPerformance(
    BuildContext context,
    GameStateService gameState,
    Venue venue,
    int performanceScore,
  ) {
    // final player = gameState.player!;
    
    // Calculate earnings
    final performanceMultiplier = performanceScore / 100;
    final earnings = (venue.basePay * performanceMultiplier).toInt();
    
    final fanGain = (venue.capacity * 0.1 * performanceMultiplier).toInt();
    
                    final achievementService = Provider.of<AchievementService>(context, listen: false);
                    final challengeService = Provider.of<ChallengeService>(context, listen: false);
                    gameState.updatePlayerMoney(earnings.toDouble(), achievementService: achievementService); // Cast to double
                    gameState.updatePlayerFanCount(fanGain, achievementService: achievementService);
                    challengeService.updateProgress(ChallengeType.performShows, 1);
                    challengeService.updateProgress(ChallengeType.gainFans, fanGain);
                    challengeService.updateProgress(ChallengeType.earnMoney, earnings);
    gameState.updatePlayerAttribute('performance', performanceScore > 70 ? 1.0 : 0.5); // Cast to double
    gameState.updatePlayerAttribute('stamina', -20.0); // Cast to double
    gameState.updatePlayerAttribute('popularity', fanGain / 100.0); // Cast to double
    gameState.recalculateCharts(); // Recalculate charts after performance
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a3e),
        title: const Text(
          'Performance Complete!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score: $performanceScore',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Earned: \$$earnings',
              style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'New Fans: +$fanGain',
              style: const TextStyle(color: Color(0xFF2196F3), fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _VenueCard extends StatelessWidget {
  final Venue venue;
  final Artist player;
  final VoidCallback onPerform;

  const _VenueCard({
    required this.venue,
    required this.player,
    required this.onPerform,
  });

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
                    color: _getVenueColor(venue.size),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_city,
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
                        venue.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Capacity: ${venue.capacity}',
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
                    Text(
                      '\$${venue.basePay}',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Base Pay',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (player.attributes['stamina'] ?? 0) >= 20 ? onPerform : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe94560),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF1a1a2e),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  (player.attributes['stamina'] ?? 0) >= 20
                      ? 'PERFORM'
                      : 'NOT ENOUGH STAMINA',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getVenueColor(VenueSize size) {
    switch (size) {
      case VenueSize.small:
        return const Color(0xFF8BC34A);
      case VenueSize.medium:
        return const Color(0xFF2196F3);
      case VenueSize.large:
        return const Color(0xFF9C27B0);
      case VenueSize.stadium:
        return const Color(0xFFFFD700);
    }
  }
}

class _LockedVenueCard extends StatelessWidget {
  final Venue venue;

  const _LockedVenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1a1a2e),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock,
                color: Colors.white38,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requires ${venue.popularityRequired} popularity',
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
