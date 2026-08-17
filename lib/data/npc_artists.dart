import '../models/artist.dart';
import '../models/label_tier.dart';
import 'record_labels.dart';
import 'dart:math';

class NPCArtists {
  static const int targetCount = 150;

  static final List<String> artistNames = [
    'Nova Sky', 'Jaxson Vibe', 'Lyric Sage', 'Echo Blaze', 'Raven Storm',
    'Phoenix Ray', 'Luna Beats', 'Kai Rhythm', 'Stella Groove', 'Zane Pulse',
    'Aria Moon', 'Blaze Knight', 'Crystal Wave', 'Dante Flow', 'Eden Spark',
    'Finn Melody', 'Gia Harmony', 'Hunter Bass', 'Ivy Chord', 'Jazz Sterling',
    'Kira Tempo', 'Leo Sonic', 'Maya Verse', 'Nash Tone', 'Olive Sound',
    'Pierce Anthem', 'Quinn Echo', 'Riley Pitch', 'Sage Rhythm', 'Tate Vibe',
    'Uma Lyric', 'Vex Shadow', 'Willow Song', 'Xander Beat', 'Yara Melody',
    'Zara Pulse', 'Ace Harmony', 'Blake Tune', 'Cleo Wave', 'Drew Chord',
    'Elle Rhythm', 'Fox Sonic', 'Gwen Verse', 'Haze Storm', 'Iris Flow',
    'Jade Tempo', 'Knox Bass', 'Lux Spark', 'Max Groove', 'Nyx Shadow',
    'Onyx Blaze', 'Piper Song', 'Quest Vibe', 'Rex Thunder', 'Sky Melody',
    'Trix Beat', 'Urban Pulse', 'Vega Star', 'Wave Rider', 'Xen Harmony',
    'York Anthem', 'Zen Flow', 'Atlas Sound', 'Bliss Tone', 'Cipher Rhythm',
    'Dusk Melody', 'Ember Spark', 'Flash Vibe', 'Glitch Beat', 'Halo Wave',
    'Icon Pulse', 'Jinx Shadow', 'Karma Groove', 'Lumen Ray', 'Mystic Chord',
    'Neon Blaze', 'Orbit Sky', 'Prism Light', 'Quantum Vibe', 'Rebel Storm',
    'Sonic Boom', 'Tempo King', 'Unity Voice', 'Vortex Spin', 'Warp Speed',
    'Xenon Glow', 'Yolo Swag', 'Zero Gravity', 'Apex Legend', 'Beats Master',
    'Crown Jewel', 'Diamond Dust', 'Electric Soul', 'Fire Starter', 'Gold Rush',
    'Hype Train', 'Ice Queen', 'Jet Setter', 'King Pin', 'Lucky Star',
    'Money Maker', 'Night Owl', 'Ocean Wave', 'Party Animal', 'Quick Silver',
    'Rio Cascade', 'Sable Drift', 'Titan Hook', 'Umbra Lane', 'Violet Amp',
    'Wren Cascade', 'XO Cipher', 'Yumi Drift', 'Zion Arc', 'Ash Monroe',
    'Brook Ellis', 'Casey Vale', 'Devon Hart', 'Ellis Quinn', 'Faye Orion',
    'Gray Sable', 'Harper Lux', 'Indie Rose', 'Jules Nova', 'Kit Avery',
    'Lane River', 'Marlow Sky', 'Noa Prestige', 'Opal Reed', 'Penn Asher',
    'Remy Cole', 'Sloane Park', 'True Benton', 'Vale Mercer', 'Wynn Hart',
    'Ari Solace', 'Blair Knox', 'Cruz Lang', 'Drew Sable', 'Eden Vale',
    'Finn Adler', 'Gale Roux', 'Hayes Kim', 'Indy Brooks', 'Joss Hale',
    'Kade Rios', 'Lennox Wu', 'Mika Stone', 'Nico Grant', 'Oakley Jin',
    'Paris Quinn', 'Quinn Sato', 'Reed Amari', 'Skye Lin', 'Tatum Cruz',
  ];

  static Artist _buildNpc(int i, Random random) {
    final Map<String, double> attributes = {
      'popularity': random.nextDouble() * 100,
      'reputation': 30 + random.nextDouble() * 70,
      'performance': 30 + random.nextDouble() * 70,
      'fame': 30 + random.nextDouble() * 70,
      'production': 30 + random.nextDouble() * 70,
      'songwriting': 30 + random.nextDouble() * 70,
      'charisma': 30 + random.nextDouble() * 70,
      'marketing': 30 + random.nextDouble() * 70,
      'networking': 30 + random.nextDouble() * 70,
      'creativity': 30 + random.nextDouble() * 70,
      'discipline': 30 + random.nextDouble() * 70,
      'stamina': 30 + random.nextDouble() * 70,
      'controversy': random.nextDouble() * 50,
      'wealth': random.nextDouble() * 100,
      'influence': random.nextDouble() * 100,
      'happiness': 50 + random.nextDouble() * 50,
      'fan_connection': 10 + random.nextDouble() * 90,
    };

    final popularity = attributes['popularity'] ?? 0;
    final labelTier = LabelTierX.forNpcPopularity(popularity, random);
    final npc = Artist(
      id: 'npc_$i',
      name: artistNames[i % artistNames.length],
      attributes: attributes,
      labelTier: labelTier,
    );
    npc.labelId = RecordLabels.assignIdFor(npc);
    return npc;
  }

  static List<Artist> generateNPCs({int count = targetCount}) {
    final random = Random();
    final List<Artist> npcs = [];
    final n = count.clamp(1, artistNames.length);
    for (int i = 0; i < n; i++) {
      npcs.add(_buildNpc(i, random));
    }
    return npcs;
  }

  /// Fill missing `npc_0`…`npc_{targetCount-1}` slots (keeps existing saves).
  static List<Artist> missingToReachTarget(Iterable<String> existingIds) {
    final have = existingIds.toSet();
    final random = Random(42);
    final out = <Artist>[];
    for (var i = 0; i < targetCount; i++) {
      final id = 'npc_$i';
      if (have.contains(id)) continue;
      out.add(_buildNpc(i, random));
    }
    return out;
  }
}
