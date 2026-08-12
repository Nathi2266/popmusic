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

  /// Share of streaming royalties the artist keeps (label takes the rest).
  double get royaltyKeep {
    switch (this) {
      case LabelTier.unsigned:
        return 1.00;
      case LabelTier.indie:
        return 0.82;
      case LabelTier.major:
        return 0.55;
      case LabelTier.superstar:
        return 0.70;
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

enum LabelDealStyle {
  standard,
  advance,
  ownership,
}

extension LabelDealStyleX on LabelDealStyle {
  String get displayName {
    switch (this) {
      case LabelDealStyle.standard:
        return 'Standard';
      case LabelDealStyle.advance:
        return '360 / Advance';
      case LabelDealStyle.ownership:
        return 'Artist-owned';
    }
  }

  String get pitch {
    switch (this) {
      case LabelDealStyle.standard:
        return 'Normal stipend and stream split.';
      case LabelDealStyle.advance:
        return 'Huge signing check + fatter weekly check. Label keeps more streams.';
      case LabelDealStyle.ownership:
        return 'Tiny advance, thinner stipend, you keep more of every stream.';
    }
  }

  double get keepAdjust {
    switch (this) {
      case LabelDealStyle.standard:
        return 0;
      case LabelDealStyle.advance:
        return -0.12;
      case LabelDealStyle.ownership:
        return 0.10;
    }
  }

  double get stipendMultiplier {
    switch (this) {
      case LabelDealStyle.standard:
        return 1.0;
      case LabelDealStyle.advance:
        return 1.40;
      case LabelDealStyle.ownership:
        return 0.65;
    }
  }

  double signingAdvance(LabelTier tier) {
    final base = switch (tier) {
      LabelTier.unsigned => 0.0,
      LabelTier.indie => 2500.0,
      LabelTier.major => 18000.0,
      LabelTier.superstar => 80000.0,
    };
    switch (this) {
      case LabelDealStyle.standard:
        return base;
      case LabelDealStyle.advance:
        return base * 2.2;
      case LabelDealStyle.ownership:
        return base * 0.25;
    }
  }

  static LabelDealStyle fromName(String? name) {
    switch (name) {
      case 'advance':
        return LabelDealStyle.advance;
      case 'ownership':
        return LabelDealStyle.ownership;
      default:
        return LabelDealStyle.standard;
    }
  }
}
