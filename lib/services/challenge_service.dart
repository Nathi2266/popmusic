import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import '../models/challenge.dart';
import '../utils/toast_service.dart';

class ChallengeService extends ChangeNotifier {
  static const String _challengesBoxName = 'challenges';
  // ignore: unused_field
  static Box? _challengesBox; // Reserved for future persistence

  final List<Challenge> _activeChallenges = [];
  final List<Challenge> _completedChallenges = [];
  
  List<Challenge> get activeChallenges => List.unmodifiable(_activeChallenges);
  List<Challenge> get completedChallenges => List.unmodifiable(_completedChallenges);

  static Future<void> init() async {
    _challengesBox = await Hive.openBox(_challengesBoxName);
  }

  ChallengeService() {
    _loadChallenges();
    _generateDailyChallenges();
    _generateWeeklyChallenges();
  }

  void _loadChallenges() {
    // Load saved challenge progress from Hive
    // This would be implemented if we want to persist challenge progress
    // if (_challengesBox != null) {
    //   // Load challenge progress
    // }
  }

  void _generateDailyChallenges() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Check if we already have today's challenges
    final existingDaily = _activeChallenges.where(
      (c) => c.frequency == ChallengeFrequency.daily && 
             c.startDate.isAtSameMomentAs(today),
    ).toList();

    if (existingDaily.isEmpty) {
      // Generate new daily challenges
      final random = Random();
      const challengeTypes = ChallengeType.values;
      
      // Generate 2-3 daily challenges
      final count = 2 + random.nextInt(2);
      for (int i = 0; i < count; i++) {
        final type = challengeTypes[random.nextInt(challengeTypes.length)];
        final challenge = _createChallenge(type, ChallengeFrequency.daily, today, tomorrow);
        _activeChallenges.add(challenge);
      }
    }
  }

  void _generateWeeklyChallenges() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    // Check if we already have this week's challenges
    final existingWeekly = _activeChallenges.where(
      (c) => c.frequency == ChallengeFrequency.weekly &&
             c.startDate.isAtSameMomentAs(startOfWeek),
    ).toList();

    if (existingWeekly.isEmpty) {
      // Generate new weekly challenges
      final random = Random();
      const challengeTypes = ChallengeType.values;
      
      // Generate 1-2 weekly challenges
      final count = 1 + random.nextInt(2);
      for (int i = 0; i < count; i++) {
        final type = challengeTypes[random.nextInt(challengeTypes.length)];
        final challenge = _createChallenge(type, ChallengeFrequency.weekly, startOfWeek, endOfWeek);
        _activeChallenges.add(challenge);
      }
    }
  }

  Challenge _createChallenge(
    ChallengeType type,
    ChallengeFrequency frequency,
    DateTime startDate,
    DateTime endDate,
  ) {
    final random = Random();
    final id = '${frequency.name}_${type.name}_${startDate.millisecondsSinceEpoch}';
    
    int targetValue;
    int rewardXp;
    double rewardMoney;
    String title;
    String description;

    switch (type) {
      case ChallengeType.releaseSongs:
        targetValue = frequency == ChallengeFrequency.daily ? 1 : 5;
        rewardXp = targetValue * 50;
        rewardMoney = targetValue * 100.0;
        title = 'Release ${targetValue > 1 ? '$targetValue Songs' : 'a Song'}';
        description = 'Release ${targetValue > 1 ? '$targetValue songs' : 'a song'} this ${frequency.name}';
        break;
      case ChallengeType.gainFans:
        targetValue = frequency == ChallengeFrequency.daily ? 100 : 1000;
        rewardXp = targetValue ~/ 10;
        rewardMoney = targetValue * 0.5;
        title = 'Gain $targetValue Fans';
        description = 'Gain $targetValue fans this ${frequency.name}';
        break;
      case ChallengeType.earnMoney:
        targetValue = frequency == ChallengeFrequency.daily ? 1000 : 10000;
        rewardXp = targetValue ~/ 20;
        rewardMoney = targetValue * 0.1;
        title = 'Earn \$$targetValue';
        description = 'Earn \$$targetValue this ${frequency.name}';
        break;
      case ChallengeType.performShows:
        targetValue = frequency == ChallengeFrequency.daily ? 1 : 3;
        rewardXp = targetValue * 75;
        rewardMoney = targetValue * 200.0;
        title = 'Perform ${targetValue > 1 ? '$targetValue Shows' : 'a Show'}';
        description = 'Complete ${targetValue > 1 ? '$targetValue performances' : 'a performance'} this ${frequency.name}';
        break;
      case ChallengeType.chartRank:
        targetValue = frequency == ChallengeFrequency.daily ? 20 : 10;
        rewardXp = (30 - targetValue) * 20;
        rewardMoney = (30 - targetValue) * 50.0;
        title = 'Reach Top $targetValue';
        description = 'Get a song in the top $targetValue this ${frequency.name}';
        break;
      case ChallengeType.levelUp:
        targetValue = 1;
        rewardXp = 0; // Level up is its own reward
        rewardMoney = 500.0;
        title = 'Level Up';
        description = 'Level up this ${frequency.name}';
        break;
    }
    
    // Remove unused random variable warning by using it
    final _ = random;

    return Challenge(
      id: id,
      title: title,
      description: description,
      type: type,
      frequency: frequency,
      targetValue: targetValue,
      rewardXp: rewardXp,
      rewardMoney: rewardMoney,
      startDate: startDate,
      endDate: endDate,
    );
  }

  void updateProgress(ChallengeType type, int amount) {
    for (var challenge in _activeChallenges) {
      if (challenge.type == type && challenge.isActive) {
        challenge.currentProgress = (challenge.currentProgress + amount).clamp(0, challenge.targetValue);
        
        if (challenge.currentProgress >= challenge.targetValue && !challenge.isCompleted) {
          _completeChallenge(challenge);
        }
        
        notifyListeners();
      }
    }
  }

  void _completeChallenge(Challenge challenge) {
    challenge.isCompleted = true;
    challenge.completedAt = DateTime.now();
    
    _activeChallenges.remove(challenge);
    _completedChallenges.add(challenge);
    
    ToastService().showSuccess(
      'Challenge Completed: ${challenge.title}!\nReward: ${challenge.rewardXp} XP, \$${challenge.rewardMoney.toStringAsFixed(0)}',
    );
    
    notifyListeners();
  }

  void claimReward(Challenge challenge) {
    if (!challenge.isCompleted) return;
    
    // Rewards are automatically given when challenge is completed
    // This method can be used for UI purposes
    notifyListeners();
  }

  void cleanupExpiredChallenges() {
    _activeChallenges.removeWhere((challenge) {
      if (challenge.isExpired) {
        if (!challenge.isCompleted) {
          _completedChallenges.add(challenge);
        }
        return true;
      }
      return false;
    });
    notifyListeners();
  }
}

