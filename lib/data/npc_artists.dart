import '../models/artist.dart';
import '../models/label_tier.dart';
import 'record_labels.dart';
import 'dart:math';

class NPCArtists {
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
    'Money Maker', 'Night Owl', 'Ocean Wave', 'Party Animal', 'Quick Silver'
  ];

  static List<Artist> generateNPCs() {
    final random = Random();
    final List<Artist> npcs = [];

    for (int i = 0; i < 100; i++) {
      final Map<String, double> attributes = {
        'popularity': random.nextDouble() * 100,
        'reputation': 30 + random.nextDouble() * 70,
        'performance': 30 + random.nextDouble() * 70,
        'talent': 30 + random.nextDouble() * 70,
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
        'happiness': 50 + random.nextDouble() * 50, // Added happiness
        'fan_connection': 10 + random.nextDouble() * 90, // Added fan_connection
      };

      final popularity = attributes['popularity'] ?? 0;
      final labelTier = LabelTierX.forNpcPopularity(popularity, random);
      final npc = Artist(
        id: 'npc_$i',
        name: artistNames[i],
        attributes: attributes,
        labelTier: labelTier,
      );
      npc.labelId = RecordLabels.assignIdFor(npc);
      npcs.add(npc);
    }

    return npcs;
  }
}
