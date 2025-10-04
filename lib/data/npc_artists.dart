import '../models/artist.dart';
import '../models/artist_attributes.dart';
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
      final attributes = ArtistAttributes(
        popularity: random.nextDouble() * 100,
        reputation: 30 + random.nextDouble() * 70,
        performance: 30 + random.nextDouble() * 70,
        talent: 30 + random.nextDouble() * 70,
        production: 30 + random.nextDouble() * 70,
        songwriting: 30 + random.nextDouble() * 70,
        charisma: 30 + random.nextDouble() * 70,
        marketing: 30 + random.nextDouble() * 70,
        networking: 30 + random.nextDouble() * 70,
        creativity: 30 + random.nextDouble() * 70,
        discipline: 30 + random.nextDouble() * 70,
        stamina: 30 + random.nextDouble() * 70,
        controversy: random.nextDouble() * 50,
        wealth: random.nextDouble() * 100,
        influence: random.nextDouble() * 100,
      );

      final primaryGenre = Genre.values[random.nextInt(Genre.values.length)];
      final hasSecondaryGenre = random.nextBool();
      Genre? secondaryGenre;
      if (hasSecondaryGenre) {
        secondaryGenre = Genre.values[random.nextInt(Genre.values.length)];
        if (secondaryGenre == primaryGenre) secondaryGenre = null;
      }

      final labelTier = _getRandomLabelTier(random, attributes.popularity);

      npcs.add(Artist(
        id: 'npc_$i',
        name: artistNames[i],
        isPlayer: false,
        primaryGenre: primaryGenre,
        secondaryGenre: secondaryGenre,
        attributes: attributes,
        labelTier: labelTier,
        money: (1000 + random.nextInt(100000)).toDouble(),
        fanCount: (attributes.popularity * 1000).toInt(),
        weeksSinceDebut: random.nextInt(520), // 0-10 years
        releasedSongs: [],
        releasedAlbums: [],
      ));
    }

    return npcs;
  }

  static LabelTier _getRandomLabelTier(Random random, double popularity) {
    if (popularity > 80) {
      return random.nextBool() ? LabelTier.superstar : LabelTier.major;
    } else if (popularity > 50) {
      return random.nextBool() ? LabelTier.major : LabelTier.indie;
    } else if (popularity > 20) {
      return random.nextBool() ? LabelTier.indie : LabelTier.unsigned;
    } else {
      return LabelTier.unsigned;
    }
  }
}
