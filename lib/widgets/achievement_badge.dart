import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/animations.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool showProgress;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showProgress = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppAnimations.fadeIn(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: achievement.isUnlocked
                ? achievement.color.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: achievement.isUnlocked
                  ? achievement.color
                  : Theme.of(context).dividerColor,
              width: achievement.isUnlocked ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.color.withValues(alpha: 0.3)
                      : Theme.of(context).dividerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              color: achievement.isUnlocked
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.72),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (achievement.isUnlocked)
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        color: achievement.isUnlocked
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.72)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.38),
                        fontSize: 12,
                      ),
                    ),
                    if (showProgress && !achievement.isUnlocked) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: achievement.progressPercentage,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          achievement.color,
                        ),
                        minHeight: 4,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${achievement.currentProgress} / ${achievement.targetValue}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

