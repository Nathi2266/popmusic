enum ChallengeType {
  releaseSongs,
  gainFans,
  earnMoney,
  performShows,
  chartRank,
  levelUp,
}

enum ChallengeFrequency {
  daily,
  weekly,
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeFrequency frequency;
  final int targetValue;
  final int rewardXp;
  final double rewardMoney;
  final DateTime startDate;
  final DateTime endDate;
  int currentProgress;
  bool isCompleted;
  DateTime? completedAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    required this.targetValue,
    required this.rewardXp,
    required this.rewardMoney,
    required this.startDate,
    required this.endDate,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.completedAt,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActive => !isExpired && !isCompleted;

  double get progressPercentage {
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  int get daysRemaining {
    final remaining = endDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json, Challenge template) {
    return Challenge(
      id: template.id,
      title: template.title,
      description: template.description,
      type: template.type,
      frequency: template.frequency,
      targetValue: template.targetValue,
      rewardXp: template.rewardXp,
      rewardMoney: template.rewardMoney,
      startDate: template.startDate,
      endDate: template.endDate,
      currentProgress: json['currentProgress'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

