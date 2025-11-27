import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/challenge_service.dart';
import '../models/challenge.dart';
import '../widgets/glass_card.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeService>(
      builder: (context, challengeService, child) {
        challengeService.cleanupExpiredChallenges();
        
        final active = challengeService.activeChallenges;
        final completed = challengeService.completedChallenges
            .where((c) => c.completedAt != null)
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Challenges'),
            backgroundColor: const Color(0xFF16213e),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Challenges
                  const Text(
                    'DAILY CHALLENGES',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...active
                      .where((c) => c.frequency == ChallengeFrequency.daily)
                      .map((challenge) => _ChallengeCard(challenge: challenge)),
                  if (active.where((c) => c.frequency == ChallengeFrequency.daily).isEmpty)
                    const GlassCard(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Colors.white38,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No daily challenges available',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Weekly Challenges
                  const Text(
                    'WEEKLY CHALLENGES',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...active
                      .where((c) => c.frequency == ChallengeFrequency.weekly)
                      .map((challenge) => _ChallengeCard(challenge: challenge)),
                  if (active.where((c) => c.frequency == ChallengeFrequency.weekly).isEmpty)
                    const GlassCard(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 48,
                              color: Colors.white38,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No weekly challenges available',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Completed Challenges
                  if (completed.isNotEmpty) ...[
                    const Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...completed.take(5).map((challenge) => _ChallengeCard(
                          challenge: challenge,
                          isCompleted: true,
                        )),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final bool isCompleted;

  const _ChallengeCard({
    required this.challenge,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: isCompleted
            ? const Color(0xFF4CAF50)
            : challenge.frequency == ChallengeFrequency.weekly
                ? const Color(0xFF9C27B0)
                : const Color(0xFF2196F3),
        borderWidth: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getChallengeIcon(challenge.type),
                            color: isCompleted
                                ? const Color(0xFF4CAF50)
                                : challenge.frequency == ChallengeFrequency.weekly
                                    ? const Color(0xFF9C27B0)
                                    : const Color(0xFF2196F3),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              challenge.title,
                              style: TextStyle(
                                color: isCompleted ? Colors.white70 : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          color: isCompleted ? Colors.white38 : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: challenge.frequency == ChallengeFrequency.weekly
                          ? const Color(0xFF9C27B0).withValues(alpha: 0.2)
                          : const Color(0xFF2196F3).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${challenge.daysRemaining}d left',
                      style: TextStyle(
                        color: challenge.frequency == ChallengeFrequency.weekly
                            ? const Color(0xFF9C27B0)
                            : const Color(0xFF2196F3),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: challenge.progressPercentage,
                backgroundColor: const Color(0xFF1a1a2e),
                valueColor: AlwaysStoppedAnimation<Color>(
                  challenge.frequency == ChallengeFrequency.weekly
                      ? const Color(0xFF9C27B0)
                      : const Color(0xFF2196F3),
                ),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${challenge.currentProgress} / ${challenge.targetValue}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      if (challenge.rewardXp > 0) ...[
                        const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.rewardXp} XP',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.attach_money, color: Color(0xFF4CAF50), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '\$${challenge.rewardMoney.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge.rewardXp} XP',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.attach_money, color: Color(0xFF4CAF50), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '\$${challenge.rewardMoney.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.releaseSongs:
        return Icons.music_note;
      case ChallengeType.gainFans:
        return Icons.people;
      case ChallengeType.earnMoney:
        return Icons.attach_money;
      case ChallengeType.performShows:
        return Icons.mic;
      case ChallengeType.chartRank:
        return Icons.trending_up;
      case ChallengeType.levelUp:
        return Icons.star;
    }
  }
}

