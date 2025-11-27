class PlayerLevel {
  final int level;
  final int xpRequired;
  final int totalXpForLevel;

  const PlayerLevel({
    required this.level,
    required this.xpRequired,
    required this.totalXpForLevel,
  });

  static int calculateLevel(int totalXp) {
    int level = 1;
    int xpNeeded = 0;
    
    while (xpNeeded <= totalXp) {
      final xpForNextLevel = _getXpForLevel(level);
      if (xpNeeded + xpForNextLevel > totalXp) {
        break;
      }
      xpNeeded += xpForNextLevel;
      level++;
    }
    
    return level;
  }

  static int getXpForNextLevel(int currentLevel) {
    return _getXpForLevel(currentLevel);
  }

  static int _getXpForLevel(int level) {
    // Exponential growth: 100 * level^1.5
    return (100 * (level * level * 0.5)).round();
  }

  static int getTotalXpForLevel(int level) {
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += _getXpForLevel(i);
    }
    return total;
  }

  static PlayerLevel fromTotalXp(int totalXp) {
    final level = calculateLevel(totalXp);
    final totalXpForCurrentLevel = getTotalXpForLevel(level);
    final xpInCurrentLevel = totalXp - totalXpForCurrentLevel;
    final xpRequired = getXpForNextLevel(level);
    
    return PlayerLevel(
      level: level,
      xpRequired: xpRequired,
      totalXpForLevel: xpInCurrentLevel,
    );
  }

  double get progressPercentage {
    if (xpRequired == 0) return 1.0;
    return (totalXpForLevel / xpRequired).clamp(0.0, 1.0);
  }

  int get xpUntilNextLevel {
    return xpRequired - totalXpForLevel;
  }
}

