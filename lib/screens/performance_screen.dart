import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../services/achievement_service.dart';
import '../services/challenge_service.dart';
import '../models/venue.dart';
import '../models/tour.dart';
import '../models/label_tier.dart';
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

        final pop = player.attributes['popularity'] ?? 0;
        final availableVenues = VenueData.venues
            .where((v) =>
                v.popularityRequired <= pop &&
                v.minLabel.index <= player.labelTier.index)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('Performances'),
                      ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Player Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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

              if (gameState.isOnTour)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF9800)),
                  ),
                  child: Text(
                    'On tour: ${gameState.activeTour!.name} · '
                    '${gameState.activeTour!.currentCity} next · '
                    '${gameState.activeTour!.weeksRemaining}w left',
                    style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              if (gameState.isFestivalSeason) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEB3B).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFEB3B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gameState.canPlayFestival
                            ? 'Summer festival slot is open'
                            : 'Festival slot already played this year',
                        style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'One exclusive set, June–August. Heat is up on Pop / Electronic / Hip-Hop.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 12),
                      ),
                      if (gameState.canPlayFestival) ...[
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            final err = gameState.playFestivalSlot();
                            if (err != null) {
                              ToastService().showError(err);
                            } else {
                              ToastService().showSuccess(
                                'Festival set done. Viral bump on your hottest track.',
                              );
                            }
                          },
                          icon: Icon(Icons.festival),
                          label: Text('Play festival slot'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              Text(
                'BOOK A TOUR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Multi-week run: door money + merch each stop, stamina each week.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 13),
              ),
              const SizedBox(height: 12),
              ...TourPackage.all.map((pack) {
                final locked = pop < pack.popularityRequired ||
                    player.labelTier.index < pack.minLabel.index;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: locked ? Colors.white24 : const Color(0xFFFF9800),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pack.name,
                              style: TextStyle(
                                color: locked ? Colors.white38 : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${pack.weeks}w · \$${pack.weeklyPay.toStringAsFixed(0)}/stop + merch · −${pack.staminaCost.toStringAsFixed(0)} stam',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 12),
                            ),
                            if (locked)
                              Text(
                                pack.minLabel.index > 0
                                    ? '${pack.minLabel.displayName} · ${pack.popularityRequired} pop'
                                    : '${pack.popularityRequired} popularity',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: locked || gameState.isOnTour
                            ? null
                            : () {
                                final err = gameState.bookTour(pack.id);
                                if (err != null) {
                                  ToastService().showError(err);
                                } else {
                                  ToastService().showSuccess(
                                    'Booked ${pack.name}. Stops start next week.',
                                  );
                                }
                              },
                        child: Text(gameState.isOnTour ? 'On tour' : 'Book'),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              Text(
                'AVAILABLE VENUES',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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
                Text(
                  'LOCKED VENUES',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                ...VenueData.venues
                    .where((v) =>
                        v.popularityRequired >
                            (player.attributes['popularity'] ?? 0) ||
                        v.minLabel.index > player.labelTier.index)
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
    gameState.updatePlayerAttribute('performance', performanceScore > 70 ? 1.0 : 0.5); // Cast to double
    gameState.updatePlayerAttribute('stamina', -20.0); // Cast to double
    gameState.updatePlayerAttribute('popularity', fanGain / 100.0); // Cast to double
    gameState.recalculateCharts(); // Recalculate charts after performance
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Performance Complete!',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score: $performanceScore',
              style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Earned: \$$earnings',
              style: TextStyle(color: Color(0xFF4CAF50), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'New Fans: +$fanGain',
              style: TextStyle(color: Color(0xFF2196F3), fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
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
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
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
      color: Theme.of(context).colorScheme.surface,
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
                  child: Icon(
                    Icons.location_city,
                    color: Theme.of(context).colorScheme.onSurface,
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
                        style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Capacity: ${venue.capacity}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
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
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Base Pay',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  disabledBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  (player.attributes['stamina'] ?? 0) >= 20
                      ? 'PERFORM'
                      : 'NOT ENOUGH STAMINA',
                  style: TextStyle(
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
      color: Theme.of(context).scaffoldBackgroundColor,
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
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Needs ${venue.popularityRequired} pop · ${venue.minLabel.displayName}+',
                    style: TextStyle(
                      color: Theme.of(context).dividerColor,
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
