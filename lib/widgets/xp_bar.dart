import 'package:flutter/material.dart';
import '../models/player_level.dart';

class XpBar extends StatelessWidget {
  final PlayerLevel playerLevel;
  final bool showLevel;
  final bool showXpText;

  const XpBar({
    super.key,
    required this.playerLevel,
    this.showLevel = true,
    this.showXpText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLevel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Level ${playerLevel.level}',
                    style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (showXpText)
                Text(
                  '${playerLevel.totalXpForLevel} / ${playerLevel.xpRequired} XP',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        if (showLevel) const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: playerLevel.progressPercentage),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: showLevel ? 12 : 8,
                backgroundColor: Theme.of(context).colorScheme.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFD700),
                ),
              );
            },
          ),
        ),
        if (showXpText && !showLevel) ...[
          const SizedBox(height: 4),
          Text(
            '${playerLevel.totalXpForLevel} / ${playerLevel.xpRequired} XP',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

