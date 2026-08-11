import 'dart:math';

enum LabelTier {
  unsigned,
  indie,
  major,
  superstar,
}

extension LabelTierX on LabelTier {
  String get displayName {
    switch (this) {
      case LabelTier.unsigned:
        return 'Unsigned';
      case LabelTier.indie:
        return 'Indie';
      case LabelTier.major:
        return 'Major';
      case LabelTier.superstar:
        return 'Superstar';
    }
  }

  /// Weekly label advance / stipend paid in proceedWeek.
  double get weeklyIncome {
    switch (this) {
      case LabelTier.unsigned:
        return 200;
      case LabelTier.indie:
        return 800;
      case LabelTier.major:
        return 2500;
      case LabelTier.superstar:
        return 8000;
    }
  }

  /// ARGB color for UI badges/cards.
  int get colorValue {
    switch (this) {
      case LabelTier.unsigned:
        return 0xFF2196F3;
      case LabelTier.indie:
        return 0xFF4CAF50;
      case LabelTier.major:
        return 0xFFFF9800;
      case LabelTier.superstar:
        return 0xFFFFD700;
    }
  }

  LabelTier? get next {
    switch (this) {
      case LabelTier.unsigned:
        return LabelTier.indie;
      case LabelTier.indie:
        return LabelTier.major;
      case LabelTier.major:
        return LabelTier.superstar;
      case LabelTier.superstar:
        return null;
    }
  }

  String get storageName => name;

  String get requirementsText {
    switch (this) {
      case LabelTier.unsigned:
        return 'Starting tier';
      case LabelTier.indie:
        return '25 Popularity, 5 Songs';
      case LabelTier.major:
        return '60 Popularity, 50K Fans, 1 Award';
      case LabelTier.superstar:
        return '85 Popularity, 500K Fans, 3 Awards';
    }
  }

  static LabelTier fromName(String? name) {
    switch (name) {
      case 'indie':
        return LabelTier.indie;
      case 'major':
        return LabelTier.major;
      case 'superstar':
        return LabelTier.superstar;
      default:
        return LabelTier.unsigned;
    }
  }

  static LabelTier forNpcPopularity(double popularity, Random random) {
    if (popularity > 80) {
      return random.nextBool() ? LabelTier.superstar : LabelTier.major;
    }
    if (popularity > 50) {
      return random.nextBool() ? LabelTier.major : LabelTier.indie;
    }
    if (popularity > 20) {
      return random.nextBool() ? LabelTier.indie : LabelTier.unsigned;
    }
    return LabelTier.unsigned;
  }
}
