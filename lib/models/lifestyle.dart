import 'label_tier.dart';

enum LuxuryCategory {
  jewelry,
  fashion,
  cars,
  houses,
  toys,
}

extension LuxuryCategoryX on LuxuryCategory {
  String get displayName {
    switch (this) {
      case LuxuryCategory.jewelry:
        return 'Jewelry';
      case LuxuryCategory.fashion:
        return 'Fashion';
      case LuxuryCategory.cars:
        return 'Cars';
      case LuxuryCategory.houses:
        return 'Houses';
      case LuxuryCategory.toys:
        return 'Toys';
    }
  }

  static LuxuryCategory fromName(String? name) {
    switch (name) {
      case 'fashion':
        return LuxuryCategory.fashion;
      case 'cars':
        return LuxuryCategory.cars;
      case 'houses':
        return LuxuryCategory.houses;
      case 'toys':
        return LuxuryCategory.toys;
      default:
        return LuxuryCategory.jewelry;
    }
  }
}

int labelRank(LabelTier tier) {
  switch (tier) {
    case LabelTier.unsigned:
      return 0;
    case LabelTier.indie:
      return 1;
    case LabelTier.major:
      return 2;
    case LabelTier.superstar:
      return 3;
  }
}

bool labelMeets(LabelTier have, LabelTier need) =>
    labelRank(have) >= labelRank(need);

class LuxuryAsset {
  final String id;
  final String name;
  final String blurb;
  final LuxuryCategory category;
  final double price;
  final double weeklyUpkeep;
  final double popularity;
  final double wealth;
  final double influence;
  final double charisma;
  final int popularityRequired;
  final LabelTier minLabel;

  const LuxuryAsset({
    required this.id,
    required this.name,
    required this.blurb,
    required this.category,
    required this.price,
    required this.weeklyUpkeep,
    this.popularity = 0,
    this.wealth = 0,
    this.influence = 0,
    this.charisma = 0,
    this.popularityRequired = 0,
    this.minLabel = LabelTier.unsigned,
  });

  static const List<LuxuryAsset> catalog = [
    LuxuryAsset(
      id: 'gold_chain',
      name: 'Gold chain',
      blurb: 'Entry flex. Photos hit different.',
      category: LuxuryCategory.jewelry,
      price: 8000,
      weeklyUpkeep: 25,
      popularity: 2,
      wealth: 4,
      charisma: 2,
    ),
    LuxuryAsset(
      id: 'diamond_studs',
      name: 'Diamond studs',
      blurb: 'Quiet money. Loud close-ups.',
      category: LuxuryCategory.jewelry,
      price: 22000,
      weeklyUpkeep: 60,
      popularity: 3,
      wealth: 6,
      charisma: 2,
      popularityRequired: 15,
    ),
    LuxuryAsset(
      id: 'iced_watch',
      name: 'Iced watch',
      blurb: 'Every handshake becomes a headline.',
      category: LuxuryCategory.jewelry,
      price: 55000,
      weeklyUpkeep: 180,
      popularity: 5,
      wealth: 10,
      influence: 2,
      popularityRequired: 30,
      minLabel: LabelTier.indie,
    ),
    LuxuryAsset(
      id: 'designer_fit',
      name: 'Designer wardrobe',
      blurb: 'Stylists stop ghosting you.',
      category: LuxuryCategory.fashion,
      price: 12000,
      weeklyUpkeep: 40,
      popularity: 1,
      wealth: 3,
      charisma: 4,
    ),
    LuxuryAsset(
      id: 'couture',
      name: 'Couture closet',
      blurb: 'Front row, not the list.',
      category: LuxuryCategory.fashion,
      price: 40000,
      weeklyUpkeep: 150,
      popularity: 3,
      wealth: 6,
      charisma: 8,
      popularityRequired: 22,
      minLabel: LabelTier.indie,
    ),
    LuxuryAsset(
      id: 'hot_hatch',
      name: 'Hot hatch',
      blurb: 'City nights, valet tips, blurry stories.',
      category: LuxuryCategory.cars,
      price: 28000,
      weeklyUpkeep: 120,
      popularity: 2,
      wealth: 5,
      popularityRequired: 10,
    ),
    LuxuryAsset(
      id: 'sports_coupe',
      name: 'Sports coupe',
      blurb: 'The video treatment writes itself.',
      category: LuxuryCategory.cars,
      price: 95000,
      weeklyUpkeep: 420,
      popularity: 6,
      wealth: 12,
      influence: 2,
      popularityRequired: 25,
      minLabel: LabelTier.indie,
    ),
    LuxuryAsset(
      id: 'hypercar',
      name: 'Hypercar',
      blurb: 'Unreleased drop. Released engine.',
      category: LuxuryCategory.cars,
      price: 1200000,
      weeklyUpkeep: 3500,
      popularity: 12,
      wealth: 20,
      influence: 6,
      popularityRequired: 55,
      minLabel: LabelTier.major,
    ),
    LuxuryAsset(
      id: 'city_loft',
      name: 'City loft',
      blurb: 'Writers rooms start coming to you.',
      category: LuxuryCategory.houses,
      price: 180000,
      weeklyUpkeep: 700,
      popularity: 4,
      wealth: 10,
      influence: 2,
      popularityRequired: 20,
      minLabel: LabelTier.indie,
    ),
    LuxuryAsset(
      id: 'beach_house',
      name: 'Beach house',
      blurb: 'Album camps with a tide chart.',
      category: LuxuryCategory.houses,
      price: 420000,
      weeklyUpkeep: 1400,
      popularity: 7,
      wealth: 14,
      influence: 4,
      popularityRequired: 40,
      minLabel: LabelTier.major,
    ),
    LuxuryAsset(
      id: 'hill_mansion',
      name: 'Hill mansion',
      blurb: 'Gates, cameras, and a rumor mill.',
      category: LuxuryCategory.houses,
      price: 1800000,
      weeklyUpkeep: 4500,
      popularity: 14,
      wealth: 22,
      influence: 8,
      popularityRequired: 70,
      minLabel: LabelTier.superstar,
    ),
    LuxuryAsset(
      id: 'speedboat',
      name: 'Speedboat',
      blurb: 'Weekend escape that still makes the feed.',
      category: LuxuryCategory.toys,
      price: 320000,
      weeklyUpkeep: 1100,
      popularity: 6,
      wealth: 10,
      popularityRequired: 45,
      minLabel: LabelTier.major,
    ),
    LuxuryAsset(
      id: 'yacht',
      name: 'Yacht',
      blurb: 'The industry comes aboard or it doesn\'t.',
      category: LuxuryCategory.toys,
      price: 2800000,
      weeklyUpkeep: 7000,
      popularity: 16,
      wealth: 25,
      influence: 10,
      popularityRequired: 75,
      minLabel: LabelTier.superstar,
    ),
    LuxuryAsset(
      id: 'private_jet',
      name: 'Private jet',
      blurb: 'No more commercial. No more excuses.',
      category: LuxuryCategory.toys,
      price: 9500000,
      weeklyUpkeep: 14000,
      popularity: 20,
      wealth: 30,
      influence: 15,
      popularityRequired: 85,
      minLabel: LabelTier.superstar,
    ),
  ];

  static LuxuryAsset? byId(String id) {
    for (final a in catalog) {
      if (a.id == id) return a;
    }
    return null;
  }
}

class InvestmentVehicle {
  final String id;
  final String name;
  final String blurb;
  final double minBuy;
  final double weeklyRate;
  final double fanKicker;
  final double royaltyShare;
  final double productionBump;
  final double marketingBump;
  final double influenceBump;
  final LabelTier minLabel;

  const InvestmentVehicle({
    required this.id,
    required this.name,
    required this.blurb,
    required this.minBuy,
    required this.weeklyRate,
    this.fanKicker = 0,
    this.royaltyShare = 0,
    this.productionBump = 0,
    this.marketingBump = 0,
    this.influenceBump = 0,
    this.minLabel = LabelTier.unsigned,
  });

  static const List<InvestmentVehicle> catalog = [
    InvestmentVehicle(
      id: 'index',
      name: 'Index fund',
      blurb: 'Boring money. It still prints.',
      minBuy: 2500,
      weeklyRate: 0.0055,
    ),
    InvestmentVehicle(
      id: 'merch_co',
      name: 'Merch imprint',
      blurb: 'Your face on tees, paid every week.',
      minBuy: 8000,
      weeklyRate: 0.0035,
      fanKicker: 0.025,
      marketingBump: 4,
    ),
    InvestmentVehicle(
      id: 'studio',
      name: 'Recording studio',
      blurb: 'Book the room. Keep the night rate.',
      minBuy: 18000,
      weeklyRate: 0.005,
      productionBump: 6,
      minLabel: LabelTier.indie,
    ),
    InvestmentVehicle(
      id: 'catalog',
      name: 'Catalog fund',
      blurb: 'Buy masters adjacent. Ride your own streams.',
      minBuy: 25000,
      weeklyRate: 0.004,
      royaltyShare: 0.08,
      minLabel: LabelTier.indie,
    ),
    InvestmentVehicle(
      id: 'rentals',
      name: 'Rental condos',
      blurb: 'Keys, tenants, and a quieter week.',
      minBuy: 60000,
      weeklyRate: 0.0085,
      minLabel: LabelTier.major,
    ),
    InvestmentVehicle(
      id: 'nightclub',
      name: 'Nightclub stake',
      blurb: 'Bottle service funds the next single.',
      minBuy: 120000,
      weeklyRate: 0.01,
      influenceBump: 3,
      minLabel: LabelTier.major,
    ),
    InvestmentVehicle(
      id: 'fashion_house',
      name: 'Fashion house',
      blurb: 'Your name on the rack, not just the chain.',
      minBuy: 350000,
      weeklyRate: 0.007,
      influenceBump: 6,
      minLabel: LabelTier.superstar,
    ),
    InvestmentVehicle(
      id: 'star_hedge',
      name: 'Star hedge',
      blurb: 'Industry money, parked in your name.',
      minBuy: 800000,
      weeklyRate: 0.0095,
      minLabel: LabelTier.superstar,
    ),
  ];

  static InvestmentVehicle? byId(String id) {
    for (final v in catalog) {
      if (v.id == id) return v;
    }
    return null;
  }

  double weeklyYield({
    required double principal,
    required int fans,
    required double royalties,
  }) {
    return principal * weeklyRate + fans * fanKicker + royalties * royaltyShare;
  }
}

class OwnedInvestment {
  final String vehicleId;
  double principal;

  OwnedInvestment({required this.vehicleId, required this.principal});

  Map<String, dynamic> toMap() => {
        'vehicleId': vehicleId,
        'principal': principal,
      };

  factory OwnedInvestment.fromMap(Map<String, dynamic> map) {
    return OwnedInvestment(
      vehicleId: map['vehicleId'] as String? ?? 'index',
      principal: (map['principal'] as num?)?.toDouble() ?? 0,
    );
  }
}
