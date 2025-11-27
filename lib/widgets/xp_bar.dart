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
                  const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Level ${playerLevel.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (showXpText)
                Text(
                  '${playerLevel.totalXpForLevel} / ${playerLevel.xpRequired} XP',
                  style: const TextStyle(
                    color: Colors.white70,
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
                backgroundColor: const Color(0xFF2a2a3e),
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

