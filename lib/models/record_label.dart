import 'label_tier.dart';

class RecordLabel {
  final String id;
  final String name;
  final LabelTier tier;
  final String city;
  final String blurb;
  final int colorValue;

  const RecordLabel({
    required this.id,
    required this.name,
    required this.tier,
    required this.city,
    required this.blurb,
    required this.colorValue,
  });

  String get displayTier => tier.displayName;

  int get pitchCost {
    switch (tier) {
      case LabelTier.unsigned:
        return 0;
      case LabelTier.indie:
        return 250;
      case LabelTier.major:
        return 900;
      case LabelTier.superstar:
        return 2800;
    }
  }
}

class RosterSigning {
  final String artistId;
  final LabelDealStyle deal;
  final int signedYear;
  final int signedMonth;
  final int signedWeek;
  bool active;

  RosterSigning({
    required this.artistId,
    required this.deal,
    required this.signedYear,
    required this.signedMonth,
    required this.signedWeek,
    this.active = true,
  });

  /// Share of the signed artist's streams the player-as-label keeps.
  double get playerCut {
    switch (deal) {
      case LabelDealStyle.standard:
        return 0.45;
      case LabelDealStyle.advance:
        return 0.58;
      case LabelDealStyle.ownership:
        return 0.28;
    }
  }

  double get artistKeep => (1.0 - playerCut).clamp(0.20, 0.90);

  Map<String, dynamic> toMap() {
    return {
      'artistId': artistId,
      'deal': deal.name,
      'signedYear': signedYear,
      'signedMonth': signedMonth,
      'signedWeek': signedWeek,
      'active': active,
    };
  }

  factory RosterSigning.fromMap(Map<String, dynamic> map) {
    return RosterSigning(
      artistId: map['artistId'] as String? ?? '',
      deal: LabelDealStyleX.fromName(map['deal'] as String?),
      signedYear: map['signedYear'] as int? ?? 2025,
      signedMonth: map['signedMonth'] as int? ?? 1,
      signedWeek: map['signedWeek'] as int? ?? 1,
      active: map['active'] as bool? ?? true,
    );
  }

  static double signingCost(double popularity, LabelDealStyle deal) {
    final base = 700.0 + popularity * 38.0;
    switch (deal) {
      case LabelDealStyle.standard:
        return base;
      case LabelDealStyle.advance:
        return base * 2.1;
      case LabelDealStyle.ownership:
        return base * 0.45;
    }
  }

  static double acceptChance({
    required double playerPopularity,
    required double playerReputation,
    required double artistPopularity,
    required LabelDealStyle deal,
  }) {
    var chance = 0.34 +
        playerReputation / 220 +
        playerPopularity / 280 -
        artistPopularity / 240;
    switch (deal) {
      case LabelDealStyle.standard:
        break;
      case LabelDealStyle.advance:
        chance += 0.14;
      case LabelDealStyle.ownership:
        chance += 0.18;
    }
    return chance.clamp(0.12, 0.92);
  }
}
