import '../models/label_tier.dart';
import '../models/record_label.dart';
import '../models/artist.dart';

class RecordLabels {
  static const String playerImprintId = 'player_imprint';
  static const int maxRosterSize = 5;
  static const int pitchCooldownWeeks = 4;
  static const int signRejectCooldownWeeks = 6;
  static const int managementCooldownWeeks = 3;

  static const List<RecordLabel> catalog = [
    RecordLabel(
      id: 'cassette_heart',
      name: 'Cassette Heart',
      tier: LabelTier.indie,
      city: 'Portland',
      blurb: 'Tape-first indie. A&R lives in basements and all-ages rooms.',
      colorValue: 0xFF4CAF50,
      ceoName: 'Marisol Pike',
      ceoTitle: 'Founder & CEO',
      ceoFocus: 'Books intimate rooms and keeps the roster touring DIY circuits.',
    ),
    RecordLabel(
      id: 'harbor_lights',
      name: 'Harbor Lights',
      tier: LabelTier.indie,
      city: 'Brighton',
      blurb: 'Coastal indie pop. Playlists over billboards.',
      colorValue: 0xFF26A69A,
      ceoName: 'Theo Lang',
      ceoTitle: 'CEO',
      ceoFocus: 'Playlist pitching and soft-launch showcase nights.',
    ),
    RecordLabel(
      id: 'neon_alley',
      name: 'Neon Alley',
      tier: LabelTier.indie,
      city: 'Seoul',
      blurb: 'Night-drive electronic and sharp hooks.',
      colorValue: 0xFF7E57C2,
      ceoName: 'Hana Cho',
      ceoTitle: 'CEO',
      ceoFocus: 'Club residencies and late-night radio drops.',
    ),
    RecordLabel(
      id: 'apex_sound',
      name: 'Apex Sound',
      tier: LabelTier.major,
      city: 'Los Angeles',
      blurb: 'Radio, video budgets, and a long legal team.',
      colorValue: 0xFFFF9800,
      ceoName: 'Victor Hale',
      ceoTitle: 'CEO',
      ceoFocus: 'Arena openers, brand nights, and radio promo runs.',
    ),
    RecordLabel(
      id: 'goldline_media',
      name: 'Goldline Media',
      tier: LabelTier.major,
      city: 'New York',
      blurb: 'East Coast major. Brand deals bundled with the deal memo.',
      colorValue: 0xFFFFB300,
      ceoName: 'Priya Mendel',
      ceoTitle: 'CEO',
      ceoFocus: 'Press weeks, TV slots, and mid-size theater runs.',
    ),
    RecordLabel(
      id: 'voltwave',
      name: 'Voltwave',
      tier: LabelTier.major,
      city: 'London',
      blurb: 'Transatlantic major. Festival slots come with the paperwork.',
      colorValue: 0xFFEF6C00,
      ceoName: 'Owen Drake',
      ceoTitle: 'CEO',
      ceoFocus: 'Festival packages and EU/UK support tours.',
    ),
    RecordLabel(
      id: 'crownworld',
      name: 'Crownworld',
      tier: LabelTier.superstar,
      city: 'Los Angeles',
      blurb: 'Stadium infrastructure. They only take what already moves units.',
      colorValue: 0xFFFFD700,
      ceoName: 'Cassandra Roy',
      ceoTitle: 'Global CEO',
      ceoFocus: 'Stadium routing, awards campaigning, and global partners.',
    ),
    RecordLabel(
      id: 'infinity_house',
      name: 'Infinity House',
      tier: LabelTier.superstar,
      city: 'Tokyo',
      blurb: 'Global superstar house. Slow inbox, huge machines.',
      colorValue: 0xFFFFC107,
      ceoName: 'Kenji Okada',
      ceoTitle: 'CEO',
      ceoFocus: 'World tours, sync deals, and flagship residency nights.',
    ),
  ];

  static RecordLabel? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final label in catalog) {
      if (label.id == id) return label;
    }
    return null;
  }

  static List<RecordLabel> forTier(LabelTier tier) =>
      catalog.where((l) => l.tier == tier).toList();

  static String assignIdFor(Artist artist) {
    if (artist.labelTier == LabelTier.unsigned) return '';
    final pool = forTier(artist.labelTier);
    if (pool.isEmpty) return '';
    final index = artist.id.hashCode.abs() % pool.length;
    return pool[index].id;
  }

  static RecordLabel playerImprint(String playerName, LabelTier tier) {
    final effective =
        tier == LabelTier.unsigned ? LabelTier.indie : tier;
    return RecordLabel(
      id: playerImprintId,
      name: '$playerName Records',
      tier: effective,
      city: 'Your city',
      blurb: 'Your imprint. Signed artists write here; you pick the release date.',
      colorValue: 0xFFe94560,
      ceoName: playerName,
      ceoTitle: 'Founder & CEO',
      ceoFocus: 'You book gigs, press, and studio blocks for your roster.',
    );
  }

  static List<RecordLabel> allVisible({
    required String playerName,
    required LabelTier playerTier,
  }) {
    return [...catalog, playerImprint(playerName, playerTier)];
  }
}
