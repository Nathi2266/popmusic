import 'label_tier.dart';

class RecordLabel {
  final String id;
  final String name;
  final LabelTier tier;
  final String city;
  final String blurb;
  final int colorValue;
  final String ceoName;
  final String ceoTitle;
  final String ceoFocus;

  const RecordLabel({
    required this.id,
    required this.name,
    required this.tier,
    required this.city,
    required this.blurb,
    required this.colorValue,
    required this.ceoName,
    required this.ceoTitle,
    required this.ceoFocus,
  });

  String get displayTier => tier.displayName;

  String get ceoLine => '$ceoTitle · $ceoName';

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

enum LabelMgmtAction {
  bookGig,
  playlistPush,
  pressDay,
  studioBlock;

  String get displayName => switch (this) {
        LabelMgmtAction.bookGig => 'Book a gig',
        LabelMgmtAction.playlistPush => 'Playlist push',
        LabelMgmtAction.pressDay => 'Press day',
        LabelMgmtAction.studioBlock => 'Studio block',
      };

  String get blurb => switch (this) {
        LabelMgmtAction.bookGig =>
          'CEO books a performance that fits the artist\'s heat.',
        LabelMgmtAction.playlistPush =>
          'Editorial playlist bump for recent releases.',
        LabelMgmtAction.pressDay =>
          'Interviews and coverage to lift reputation.',
        LabelMgmtAction.studioBlock =>
          'Paid studio time to sharpen craft for the next release.',
      };
}

class RosterSigning {
  final String artistId;
  final LabelDealStyle deal;
  final int signedYear;
  final int signedMonth;
  final int signedWeek;
  bool active;
  /// Player's share of this artist's streams. Null = use [deal] default.
  double? customPlayerCut;

  RosterSigning({
    required this.artistId,
    required this.deal,
    required this.signedYear,
    required this.signedMonth,
    required this.signedWeek,
    this.active = true,
    this.customPlayerCut,
  });

  /// Share of the signed artist's streams the player-as-label keeps.
  double get playerCut {
    final custom = customPlayerCut;
    if (custom != null) return custom.clamp(0.15, 0.80);
    return playerCutForDeal(deal);
  }

  double get artistKeep => (1.0 - playerCut).clamp(0.20, 0.85);

  Map<String, dynamic> toMap() {
    return {
      'artistId': artistId,
      'deal': deal.name,
      'signedYear': signedYear,
      'signedMonth': signedMonth,
      'signedWeek': signedWeek,
      'active': active,
      if (customPlayerCut != null) 'playerCut': customPlayerCut,
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
      customPlayerCut: (map['playerCut'] as num?)?.toDouble(),
    );
  }

  static double playerCutForDeal(LabelDealStyle deal) {
    switch (deal) {
      case LabelDealStyle.standard:
        return 0.45;
      case LabelDealStyle.advance:
        return 0.58;
      case LabelDealStyle.ownership:
        return 0.28;
    }
  }

  static double artistKeepForDeal(LabelDealStyle deal) =>
      (1.0 - playerCutForDeal(deal)).clamp(0.20, 0.85);

  static LabelDealStyle closestDeal(double artistKeep) {
    var best = LabelDealStyle.standard;
    var bestDelta = 99.0;
    for (final deal in LabelDealStyle.values) {
      final delta = (artistKeepForDeal(deal) - artistKeep).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        best = deal;
      }
    }
    return best;
  }

  static double signingCost(double popularity, LabelDealStyle deal) {
    return signingCostForKeep(popularity, artistKeepForDeal(deal));
  }

  static double signingCostForKeep(double popularity, double artistKeep) {
    final playerShare = (1.0 - artistKeep).clamp(0.15, 0.80);
    final base = 700.0 + popularity * 38.0;
    return base * (0.55 + playerShare);
  }

  /// Minimum royalty the artist must keep, from their career level.
  static double minArtistKeep({
    required LabelTier tier,
    required double popularity,
  }) {
    final floor = switch (tier) {
      LabelTier.unsigned => 0.42,
      LabelTier.indie => 0.52,
      LabelTier.major => 0.64,
      LabelTier.superstar => 0.74,
    };
    final heat = ((popularity - 40).clamp(0.0, 40.0)) * 0.002;
    return (floor + heat).clamp(0.38, 0.82);
  }

  static ContractEvaluation evaluate({
    required String artistName,
    required LabelTier tier,
    required double popularity,
    required double artistKeep,
  }) {
    final keep = artistKeep.clamp(0.20, 0.85);
    final minKeep = minArtistKeep(tier: tier, popularity: popularity);
    final cost = signingCostForKeep(popularity, keep);
    final pct = (minKeep * 100).round();
    final offered = (keep * 100).round();
    if (keep + 0.0001 < minKeep) {
      final preset = closestDeal(minKeep);
      return ContractEvaluation(
        acceptable: false,
        minArtistKeep: minKeep,
        artistKeep: keep,
        playerCut: (1.0 - keep).clamp(0.15, 0.80),
        signingCost: cost,
        levelLabel: tier.displayName,
        message:
            '$artistName: this deal is too small. At ${tier.displayName} '
            '($offered% for me) I will not sign.',
        suggestion:
            'Raise their royalties to at least $pct% '
            '(try ${preset.displayName}, they keep ${(artistKeepForDeal(preset) * 100).round()}%).',
      );
    }
    return ContractEvaluation(
      acceptable: true,
      minArtistKeep: minKeep,
      artistKeep: keep,
      playerCut: (1.0 - keep).clamp(0.15, 0.80),
      signingCost: cost,
      levelLabel: tier.displayName,
      message:
          '$artistName will sign. They keep $offered% · you keep '
          '${((1.0 - keep) * 100).round()}%.',
      suggestion: null,
    );
  }

  static double acceptChance({
    required double playerPopularity,
    required double playerReputation,
    required double artistPopularity,
    required LabelDealStyle deal,
  }) {
    final eval = evaluate(
      artistName: 'Artist',
      tier: artistPopularity > 80
          ? LabelTier.superstar
          : artistPopularity > 50
              ? LabelTier.major
              : artistPopularity > 20
                  ? LabelTier.indie
                  : LabelTier.unsigned,
      popularity: artistPopularity,
      artistKeep: artistKeepForDeal(deal),
    );
    return eval.acceptable ? 1.0 : 0.0;
  }
}

class ContractEvaluation {
  final bool acceptable;
  final double minArtistKeep;
  final double artistKeep;
  final double playerCut;
  final double signingCost;
  final String levelLabel;
  final String message;
  final String? suggestion;

  const ContractEvaluation({
    required this.acceptable,
    required this.minArtistKeep,
    required this.artistKeep,
    required this.playerCut,
    required this.signingCost,
    required this.levelLabel,
    required this.message,
    this.suggestion,
  });
}
