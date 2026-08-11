import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import '../models/challenge.dart';
import '../utils/toast_service.dart';
import 'game_state_service.dart';

class ChallengeService extends ChangeNotifier {
  static const String _challengesBoxName = 'challenges';
  // ignore: unused_field
  static Box? _challengesBox;

  GameStateService? _game;

  final List<Challenge> _activeChallenges = [];
  final List<Challenge> _completedChallenges = [];

  List<Challenge> get activeChallenges => List.unmodifiable(_activeChallenges);
  List<Challenge> get completedChallenges =>
      List.unmodifiable(_completedChallenges);

  static Future<void> init() async {
    _challengesBox = await Hive.openBox(_challengesBoxName);
  }

  ChallengeService() {
    _loadChallenges();
    _generateDailyChallenges();
    _generateWeeklyChallenges();
  }

  void attachGame(GameStateService game) {
    _game = game;
  }

  void _loadChallenges() {
    // Persistence reserved for a later cycle
  }

  void _generateDailyChallenges() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final existingDaily = _activeChallenges
        .where(
          (c) =>
              c.frequency == ChallengeFrequency.daily &&
              c.startDate.isAtSameMomentAs(today),
        )
        .toList();

    if (existingDaily.isEmpty) {
      final random = Random();
      const challengeTypes = ChallengeType.values;
      final count = 2 + random.nextInt(2);
      for (int i = 0; i < count; i++) {
        final type = challengeTypes[random.nextInt(challengeTypes.length)];
        _activeChallenges.add(
          _createChallenge(type, ChallengeFrequency.daily, today, tomorrow),
        );
      }
    }
  }

  void _generateWeeklyChallenges() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final existingWeekly = _activeChallenges
        .where(
          (c) =>
              c.frequency == ChallengeFrequency.weekly &&
              c.startDate.isAtSameMomentAs(startOfWeek),
        )
        .toList();

    if (existingWeekly.isEmpty) {
      final random = Random();
      const challengeTypes = ChallengeType.values;
      final count = 1 + random.nextInt(2);
      for (int i = 0; i < count; i++) {
        final type = challengeTypes[random.nextInt(challengeTypes.length)];
        _activeChallenges.add(
          _createChallenge(
            type,
            ChallengeFrequency.weekly,
            startOfWeek,
            endOfWeek,
          ),
        );
      }
    }
  }

  Challenge _createChallenge(
    ChallengeType type,
    ChallengeFrequency frequency,
    DateTime startDate,
    DateTime endDate,
  ) {
    final id =
        '${frequency.name}_${type.name}_${startDate.millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    late final int targetValue;
    late final int rewardXp;
    late final double rewardMoney;
    late final String title;
    late final String description;

    switch (type) {
      case ChallengeType.releaseSongs:
        targetValue = frequency == ChallengeFrequency.daily ? 1 : 5;
        rewardXp = targetValue * 50;
        rewardMoney = targetValue * 100.0;
        title = 'Release ${targetValue > 1 ? '$targetValue Songs' : 'a Song'}';
        description =
            'Release ${targetValue > 1 ? '$targetValue songs' : 'a song'} this ${frequency.name}';
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
        description =
            'Complete ${targetValue > 1 ? '$targetValue performances' : 'a performance'} this ${frequency.name}';
        break;
      case ChallengeType.chartRank:
        targetValue = frequency == ChallengeFrequency.daily ? 20 : 10;
        rewardXp = (30 - targetValue) * 20;
        rewardMoney = (30 - targetValue) * 50.0;
        title = 'Reach Top $targetValue';
        description =
            'Get a song in the top $targetValue this ${frequency.name}';
        break;
      case ChallengeType.levelUp:
        targetValue = 1;
        rewardXp = 0;
        rewardMoney = 500.0;
        title = 'Level Up';
        description = 'Level up this ${frequency.name}';
        break;
    }

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
    if (amount <= 0) return;
    final snapshot = List<Challenge>.from(_activeChallenges);
    for (final challenge in snapshot) {
      if (challenge.type == type && challenge.isActive) {
        challenge.currentProgress =
            (challenge.currentProgress + amount).clamp(0, challenge.targetValue);
        if (challenge.currentProgress >= challenge.targetValue &&
            !challenge.isCompleted) {
          _completeChallenge(challenge);
        }
      }
    }
    notifyListeners();
  }

  /// Chart challenges: lower rank is better; completes when bestRank <= target.
  void updateChartRankProgress(int bestRank) {
    if (bestRank <= 0) return;
    final snapshot = List<Challenge>.from(_activeChallenges);
    for (final challenge in snapshot) {
      if (challenge.type == ChallengeType.chartRank && challenge.isActive) {
        if (bestRank <= challenge.targetValue) {
          challenge.currentProgress = challenge.targetValue;
          _completeChallenge(challenge);
        }
      }
    }
    notifyListeners();
  }

  void _completeChallenge(Challenge challenge) {
    if (challenge.isCompleted) return;
    challenge.isCompleted = true;
    challenge.completedAt = DateTime.now();

    _activeChallenges.remove(challenge);
    _completedChallenges.add(challenge);

    if (_game != null) {
      if (challenge.rewardXp > 0) {
        _game!.addPlayerXp(challenge.rewardXp, countTowardChallenges: false);
      }
      if (challenge.rewardMoney > 0) {
        _game!.updatePlayerMoney(
          challenge.rewardMoney,
          countTowardChallenges: false,
        );
      }
      challenge.rewardClaimed = true;
    }

    ToastService().showSuccess(
      'Challenge Completed: ${challenge.title}!\nReward: ${challenge.rewardXp} XP, \$${challenge.rewardMoney.toStringAsFixed(0)}',
    );

    notifyListeners();
  }

  void claimReward(Challenge challenge) {
    if (!challenge.isCompleted || challenge.rewardClaimed || _game == null) {
      return;
    }
    if (challenge.rewardXp > 0) {
      _game!.addPlayerXp(challenge.rewardXp, countTowardChallenges: false);
    }
    if (challenge.rewardMoney > 0) {
      _game!.updatePlayerMoney(
        challenge.rewardMoney,
        countTowardChallenges: false,
      );
    }
    challenge.rewardClaimed = true;
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
