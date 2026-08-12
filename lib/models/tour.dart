import 'label_tier.dart';

class TourPackage {
  final String id;
  final String name;
  final int weeks;
  final double weeklyPay;
  final double weeklyMerch;
  final int weeklyFans;
  final double staminaCost;
  final int popularityRequired;
  final LabelTier minLabel;

  const TourPackage({
    required this.id,
    required this.name,
    required this.weeks,
    required this.weeklyPay,
    required this.weeklyMerch,
    required this.weeklyFans,
    required this.staminaCost,
    required this.popularityRequired,
    this.minLabel = LabelTier.unsigned,
  });

  static const List<TourPackage> all = [
    TourPackage(
      id: 'bar_crawl',
      name: 'Bar Crawl',
      weeks: 2,
      weeklyPay: 420,
      weeklyMerch: 80,
      weeklyFans: 40,
      staminaCost: 14,
      popularityRequired: 0,
    ),
    TourPackage(
      id: 'club_circuit',
      name: 'Club Circuit',
      weeks: 3,
      weeklyPay: 1100,
      weeklyMerch: 220,
      weeklyFans: 120,
      staminaCost: 18,
      popularityRequired: 20,
    ),
    TourPackage(
      id: 'theater_run',
      name: 'Theater Run',
      weeks: 3,
      weeklyPay: 2800,
      weeklyMerch: 480,
      weeklyFans: 280,
      staminaCost: 20,
      popularityRequired: 35,
      minLabel: LabelTier.indie,
    ),
    TourPackage(
      id: 'arena_tour',
      name: 'Arena Tour',
      weeks: 4,
      weeklyPay: 18000,
      weeklyMerch: 2200,
      weeklyFans: 1800,
      staminaCost: 24,
      popularityRequired: 70,
      minLabel: LabelTier.major,
    ),
    TourPackage(
      id: 'stadium_run',
      name: 'Stadium Run',
      weeks: 4,
      weeklyPay: 90000,
      weeklyMerch: 9000,
      weeklyFans: 8000,
      staminaCost: 28,
      popularityRequired: 85,
      minLabel: LabelTier.superstar,
    ),
  ];

  static TourPackage? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}

class ActiveTour {
  final String packageId;
  final String name;
  int weeksRemaining;
  final int weeksTotal;
  int stopIndex;

  ActiveTour({
    required this.packageId,
    required this.name,
    required this.weeksRemaining,
    required this.weeksTotal,
    this.stopIndex = 0,
  });

  static const cities = [
    'Austin',
    'Nashville',
    'Chicago',
    'Brooklyn',
    'Atlanta',
    'Seattle',
    'Miami',
    'Denver',
    'London',
    'Tokyo',
  ];

  String get currentCity => cities[stopIndex % cities.length];

  Map<String, dynamic> toMap() => {
        'packageId': packageId,
        'name': name,
        'weeksRemaining': weeksRemaining,
        'weeksTotal': weeksTotal,
        'stopIndex': stopIndex,
      };

  factory ActiveTour.fromMap(Map<String, dynamic> map) {
    return ActiveTour(
      packageId: map['packageId'] as String? ?? 'bar_crawl',
      name: map['name'] as String? ?? 'Tour',
      weeksRemaining: map['weeksRemaining'] as int? ?? 0,
      weeksTotal: map['weeksTotal'] as int? ?? 2,
      stopIndex: map['stopIndex'] as int? ?? 0,
    );
  }
}
