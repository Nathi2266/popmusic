import 'package:flutter/material.dart';

enum AchievementType {
  song,
  performance,
  fan,
  money,
  chart,
  career,
  milestone,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int targetValue;
  final String icon;
  final Color color;
  int currentProgress;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.icon,
    required this.color,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressPercentage {
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json, Achievement template) {
    return Achievement(
      id: template.id,
      title: template.title,
      description: template.description,
      type: template.type,
      targetValue: template.targetValue,
      icon: template.icon,
      color: template.color,
      currentProgress: json['currentProgress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }
}

class AchievementDefinitions {
  static List<Achievement> getAllAchievements() {
    return [
      // Song Achievements
      Achievement(
        id: 'first_song',
        title: 'First Hit',
        description: 'Release your first song',
        type: AchievementType.song,
        targetValue: 1,
        icon: '🎵',
        color: const Color(0xFFe94560),
      ),
      Achievement(
        id: 'ten_songs',
        title: 'Prolific Artist',
        description: 'Release 10 songs',
        type: AchievementType.song,
        targetValue: 10,
        icon: '🎶',
        color: const Color(0xFF9C27B0),
      ),
      Achievement(
        id: 'fifty_songs',
        title: 'Music Machine',
        description: 'Release 50 songs',
        type: AchievementType.song,
        targetValue: 50,
        icon: '🎼',
        color: const Color(0xFF673AB7),
      ),

      // Performance Achievements
      Achievement(
        id: 'first_performance',
        title: 'Stage Debut',
        description: 'Complete your first performance',
        type: AchievementType.performance,
        targetValue: 1,
        icon: '🎤',
        color: const Color(0xFF2196F3),
      ),
      Achievement(
        id: 'ten_performances',
        title: 'Road Warrior',
        description: 'Complete 10 performances',
        type: AchievementType.performance,
        targetValue: 10,
        icon: '🎸',
        color: const Color(0xFF03A9F4),
      ),

      // Fan Achievements
      Achievement(
        id: 'thousand_fans',
        title: 'Rising Star',
        description: 'Reach 1,000 fans',
        type: AchievementType.fan,
        targetValue: 1000,
        icon: '⭐',
        color: const Color(0xFFFFD700),
      ),
      Achievement(
        id: 'ten_thousand_fans',
        title: 'Popular Artist',
        description: 'Reach 10,000 fans',
        type: AchievementType.fan,
        targetValue: 10000,
        icon: '🌟',
        color: const Color(0xFFFF9800),
      ),
      Achievement(
        id: 'hundred_thousand_fans',
        title: 'Superstar',
        description: 'Reach 100,000 fans',
        type: AchievementType.fan,
        targetValue: 100000,
        icon: '💫',
        color: const Color(0xFFE91E63),
      ),

      // Money Achievements
      Achievement(
        id: 'ten_thousand_money',
        title: 'Making It',
        description: 'Earn \$10,000',
        type: AchievementType.money,
        targetValue: 10000,
        icon: '💰',
        color: const Color(0xFF4CAF50),
      ),
      Achievement(
        id: 'hundred_thousand_money',
        title: 'Wealthy Artist',
        description: 'Earn \$100,000',
        type: AchievementType.money,
        targetValue: 100000,
        icon: '💎',
        color: const Color(0xFF00BCD4),
      ),

      // Chart Achievements
      Achievement(
        id: 'top_ten',
        title: 'Top 10',
        description: 'Reach top 10 on the charts',
        type: AchievementType.chart,
        targetValue: 10,
        icon: '🏆',
        color: const Color(0xFFFFD700),
      ),
      Achievement(
        id: 'number_one',
        title: 'Chart Topper',
        description: 'Reach #1 on the charts',
        type: AchievementType.chart,
        targetValue: 1,
        icon: '👑',
        color: const Color(0xFFFFD700),
      ),

      // Career Achievements
      Achievement(
        id: 'first_award',
        title: 'Award Winner',
        description: 'Win your first award',
        type: AchievementType.career,
        targetValue: 1,
        icon: '🏅',
        color: const Color(0xFFFFD700),
      ),
      Achievement(
        id: 'five_awards',
        title: 'Award Collector',
        description: 'Win 5 awards',
        type: AchievementType.career,
        targetValue: 5,
        icon: '🎖️',
        color: const Color(0xFFFFD700),
      ),
    ];
  }
}

