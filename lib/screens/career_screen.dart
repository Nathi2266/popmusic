import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../services/achievement_service.dart';
import '../models/label_tier.dart';
import '../screens/award_detail_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/lifestyle_screen.dart';
import '../screens/labels_screen.dart';
import '../widgets/empty_state.dart';
import '../utils/toast_service.dart';
import '../theme/game_palette.dart';

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
            title: Text('Career'),
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
                        style: TextStyle(
                          color: GamePalette.contrastOn(
                            Color(player.labelTier.colorValue),
                          ),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (gameState.labelDisplayName(player) !=
                          player.labelTier.displayName) ...[
                        const SizedBox(height: 4),
                        Text(
                          gameState.labelDisplayName(player),
                          style: TextStyle(
                            color: GamePalette.contrastOn(
                              Color(player.labelTier.colorValue),
                            ),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        player.labelTier == LabelTier.unsigned
                            ? 'Weekly income \$${gameState.effectiveWeeklyStipend.toStringAsFixed(0)} · keep ${(gameState.effectiveRoyaltyKeep * 100).toStringAsFixed(0)}% of streams'
                            : '${gameState.labelDealStyle.displayName} deal · stipend \$${gameState.effectiveWeeklyStipend.toStringAsFixed(0)}/wk · keep ${(gameState.effectiveRoyaltyKeep * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: GamePalette.contrastOnMuted(
                            Color(player.labelTier.colorValue),
                          ),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (gameState.fanClubFounded)
                        Text(
                          'Fan club: ${gameState.fanClubMembers} members · \$${gameState.fanClubUpkeep.toStringAsFixed(0)}/wk',
                          style: TextStyle(
                            color: GamePalette.contrastOnMuted(
                              Color(player.labelTier.colorValue),
                            ),
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        'Chapter: ${gameState.currentChapter}',
                        style: TextStyle(
                          color: GamePalette.contrastOn(
                            Color(player.labelTier.colorValue),
                          ),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(player.attributes['weeksSinceDebut'] ?? 0).toInt()} weeks in the industry',
                        style: TextStyle(
                          color: GamePalette.contrastOnMuted(
                            Color(player.labelTier.colorValue),
                          ),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LifestyleScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.diamond_outlined),
                    label: Text(
                      gameState.ownedAssetIds.isEmpty &&
                              gameState.investments.isEmpty
                          ? 'Lifestyle & investments'
                          : 'Lifestyle · net \$${gameState.lifestyleNetWorth.toStringAsFixed(0)}',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFD700),
                      side: const BorderSide(color: Color(0xFFFFD700)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LabelsScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.album_outlined),
                    label: Text(
                      gameState.activeRoster.isEmpty
                          ? 'Record labels & your imprint'
                          : 'Imprint roster ${gameState.activeRoster.length}/5',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'STORYLINE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                _StoryBeatRow(
                  title: 'Unsigned Hustle',
                  done: gameState.completedStoryBeats.contains('opening_hustle'),
                ),
                _StoryBeatRow(
                  title: 'Debut Single',
                  done: gameState.completedStoryBeats.contains('debut_single'),
                ),
                _StoryBeatRow(
                  title: 'The Clip (Scandal)',
                  done: gameState.completedStoryBeats.contains('first_scandal_arc'),
                ),
                _StoryBeatRow(
                  title: 'Indie Offer',
                  done: gameState.completedStoryBeats.contains('indie_label_fork'),
                ),
                _StoryBeatRow(
                  title: 'Rival Feud',
                  done: gameState.completedStoryBeats.contains('rival_feud'),
                ),
                _StoryBeatRow(
                  title: 'Festival Breakthrough',
                  done: gameState.completedStoryBeats.contains('festival_breakthrough'),
                ),
                _StoryBeatRow(
                  title: 'Viral Season',
                  done: gameState.completedStoryBeats.contains('viral_season'),
                ),
                _StoryBeatRow(
                  title: 'Major Label Fork',
                  done: gameState.completedStoryBeats.contains('major_label_fork'),
                ),
                const SizedBox(height: 24),

                Text(
                  'LABEL PROGRESSION',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
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
                    Text(
                      'ACHIEVEMENTS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
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
                      icon: Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                      label: Text('View All', style: TextStyle(color: Color(0xFFFFD700))),
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
                            color: Theme.of(context).colorScheme.surface,
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
                                style: TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      achievement.title,
                                      style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      achievement.description,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
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
                Text(
                  'AWARDS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: Color(0xFFFFD700),
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    award,
                                    style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
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
                Text(
                  'CAREER STATISTICS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _StatRow(
                        label: 'Total Songs Released',
                        value: '${gameState.worldSongs.where((s) => s.artistId == player.id).length}',
                        icon: Icons.music_note,
                      ),
                      Divider(color: Theme.of(context).dividerColor),
                      _StatRow(
                        label: 'Total Albums',
                        value: '${gameState.playerAlbums.length}',
                        icon: Icons.album,
                      ),
                      Divider(color: Theme.of(context).dividerColor),
                      _StatRow(
                        label: 'Total Fans',
                        value: '${gameState.playerFanCount}',
                        icon: Icons.people,
                      ),
                      Divider(color: Theme.of(context).dividerColor),
                      _StatRow(
                        label: 'Career Earnings',
                        value: '\$${gameState.playerMoney.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                      ),
                      Divider(color: Theme.of(context).dividerColor),
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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Sign ${tier.displayName}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pick the deal. This sets your stipend and stream cut until you sign up again.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 13),
              ),
              const SizedBox(height: 12),
              ...LabelDealStyle.values.map(
                (deal) => _DealOption(
                  tier: tier,
                  deal: deal,
                  onPick: () {
                    Navigator.pop(ctx);
                    final ok = gameState.upgradeLabelTier(tier, deal: deal);
                    if (ok) {
                      ToastService().showSuccess(
                        '${tier.displayName} · ${deal.displayName}',
                      );
                    } else {
                      ToastService().showError(
                        'Requirements not met for ${tier.displayName}',
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DealOption extends StatelessWidget {
  final LabelTier tier;
  final LabelDealStyle deal;
  final VoidCallback onPick;

  const _DealOption({
    required this.tier,
    required this.deal,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final keep =
        (tier.royaltyKeep + deal.keepAdjust).clamp(0.40, 0.95);
    final stipend = tier.weeklyIncome * deal.stipendMultiplier;
    final advance = deal.signingAdvance(tier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onPick,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          side: BorderSide(color: Theme.of(context).dividerColor),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.centerLeft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deal.displayName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              deal.pitch,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Advance \$${advance.toStringAsFixed(0)} · '
              '\$${stipend.toStringAsFixed(0)}/wk · '
              'keep ${(keep * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Color(0xFFFFD700), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryBeatRow extends StatelessWidget {
  final String title;
  final bool done;

  const _StoryBeatRow({required this.title, required this.done});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: done ? const Color(0xFF4CAF50) : p.divider,
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? const Color(0xFF4CAF50) : p.textFaint,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: done ? p.text : p.textMuted,
                fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
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
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? color : p.divider,
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
            color: isUnlocked ? color : p.textFaint,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.displayName,
                  style: TextStyle(
                    color: isUnlocked ? p.text : p.textMuted,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  requirements,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 12),
                ),
                Text(
                  '\$${tier.weeklyIncome.toStringAsFixed(0)}/week · ${(tier.royaltyKeep * 100).toStringAsFixed(0)}% streams',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Chip(
              label: Text('Current'),
              backgroundColor: color.withAlpha(80),
              labelStyle: TextStyle(color: GamePalette.contrastOn(color)),
            )
          else if (onUpgrade != null)
            ElevatedButton(
              onPressed: onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
              ),
              child: Text('Sign'),
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
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
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
