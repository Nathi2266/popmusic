import '../models/label_tier.dart';
import '../models/record_label.dart';
import '../models/artist.dart';

class RecordLabels {
  static const String playerImprintId = 'player_imprint';
  static const int maxRosterSize = 5;
  static const int pitchCooldownWeeks = 4;
  static const int signRejectCooldownWeeks = 6;

  static const List<RecordLabel> catalog = [
    RecordLabel(
      id: 'cassette_heart',
      name: 'Cassette Heart',
      tier: LabelTier.indie,
      city: 'Portland',
      blurb: 'Tape-first indie. A&R lives in basements and all-ages rooms.',
      colorValue: 0xFF4CAF50,
    ),
    RecordLabel(
      id: 'harbor_lights',
      name: 'Harbor Lights',
      tier: LabelTier.indie,
      city: 'Brighton',
      blurb: 'Coastal indie pop. Playlists over billboards.',
      colorValue: 0xFF26A69A,
    ),
    RecordLabel(
      id: 'neon_alley',
      name: 'Neon Alley',
      tier: LabelTier.indie,
      city: 'Seoul',
      blurb: 'Night-drive electronic and sharp hooks.',
      colorValue: 0xFF7E57C2,
    ),
    RecordLabel(
      id: 'apex_sound',
      name: 'Apex Sound',
      tier: LabelTier.major,
      city: 'Los Angeles',
      blurb: 'Radio, video budgets, and a long legal team.',
      colorValue: 0xFFFF9800,
    ),
    RecordLabel(
      id: 'goldline_media',
      name: 'Goldline Media',
      tier: LabelTier.major,
      city: 'New York',
      blurb: 'East Coast major. Brand deals bundled with the deal memo.',
      colorValue: 0xFFFFB300,
    ),
    RecordLabel(
      id: 'voltwave',
      name: 'Voltwave',
      tier: LabelTier.major,
      city: 'London',
      blurb: 'Transatlantic major. Festival slots come with the paperwork.',
      colorValue: 0xFFEF6C00,
    ),
    RecordLabel(
      id: 'crownworld',
      name: 'Crownworld',
      tier: LabelTier.superstar,
      city: 'Los Angeles',
      blurb: 'Stadium infrastructure. They only take what already moves units.',
      colorValue: 0xFFFFD700,
    ),
    RecordLabel(
      id: 'infinity_house',
      name: 'Infinity House',
      tier: LabelTier.superstar,
      city: 'Tokyo',
      blurb: 'Global superstar house. Slow inbox, huge machines.',
      colorValue: 0xFFFFC107,
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
    );
  }

  static List<RecordLabel> allVisible({
    required String playerName,
    required LabelTier playerTier,
  }) {
    return [...catalog, playerImprint(playerName, playerTier)];
  }
}
