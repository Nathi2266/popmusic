import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/achievement.dart';
import '../utils/toast_service.dart';

class AchievementService extends ChangeNotifier {
  static const String _achievementsBoxName = 'achievements';
  static Box? _achievementsBox;

  List<Achievement> _achievements = [];
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  static Future<void> init() async {
    _achievementsBox = await Hive.openBox(_achievementsBoxName);
  }

  AchievementService() {
    _loadAchievements();
  }

  void _loadAchievements() {
    final definitions = AchievementDefinitions.getAllAchievements();
    _achievements = definitions.map((def) {
      if (_achievementsBox == null) return def;
      
      final saved = _achievementsBox!.get(def.id);
      if (saved != null) {
        return Achievement.fromJson(saved as Map<String, dynamic>, def);
      }
      return def;
    }).toList();
    notifyListeners();
  }

  Future<void> _saveAchievement(Achievement achievement) async {
    await _achievementsBox?.put(achievement.id, achievement.toJson());
  }

  void updateProgress(String achievementId, int progress) {
    final achievement = _achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found: $achievementId'),
    );

    if (achievement.isUnlocked) return;

    achievement.currentProgress = progress;
    
    if (achievement.currentProgress >= achievement.targetValue && !achievement.isUnlocked) {
      achievement.isUnlocked = true;
      achievement.unlockedAt = DateTime.now();
      _saveAchievement(achievement);
      _notifyUnlock(achievement);
    } else {
      _saveAchievement(achievement);
    }
    
    notifyListeners();
  }

  void incrementProgress(String achievementId, {int amount = 1}) {
    final achievement = _achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found: $achievementId'),
    );

    if (achievement.isUnlocked) return;

    updateProgress(achievementId, achievement.currentProgress + amount);
  }

  void _notifyUnlock(Achievement achievement) {
    ToastService().showSuccess(
      'Achievement Unlocked: ${achievement.title}!',
      icon: Icons.emoji_events,
    );
  }

  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> getLockedAchievements() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }

  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  int getTotalUnlockedCount() {
    return _achievements.where((a) => a.isUnlocked).length;
  }

  double getCompletionPercentage() {
    if (_achievements.isEmpty) return 0.0;
    return (_achievements.where((a) => a.isUnlocked).length / _achievements.length) * 100;
  }
}

