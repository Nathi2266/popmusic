import 'artist_attributes.dart';

enum Genre {
  pop,
  rock,
  hiphop,
  rnb,
  electronic,
  indie,
  country,
  jazz,
  latin,
  kpop
}

enum LabelTier {
  unsigned,
  indie,
  major,
  superstar
}

class Artist {
  final String id;
  final String name;
  final bool isPlayer;
  Genre primaryGenre;
  Genre? secondaryGenre;
  ArtistAttributes attributes;
  LabelTier labelTier;
  int money;
  int fanCount;
  List<String> releasedSongs;
  List<String> releasedAlbums;
  Map<String, int> relationships; // artistId -> relationship value (-100 to 100)
  List<String> awards;
  int weeksSinceDebut;
  bool isRetired;

  Artist({
    required this.id,
    required this.name,
    required this.isPlayer,
    required this.primaryGenre,
    this.secondaryGenre,
    required this.attributes,
    this.labelTier = LabelTier.unsigned,
    this.money = 1000,
    this.fanCount = 0,
    this.releasedSongs = [],
    this.releasedAlbums = [],
    this.relationships = const {},
    this.awards = [],
    this.weeksSinceDebut = 0,
    this.isRetired = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isPlayer': isPlayer,
      'primaryGenre': primaryGenre.toString(),
      'secondaryGenre': secondaryGenre?.toString(),
      'attributes': attributes.toMap(),
      'labelTier': labelTier.toString(),
      'money': money,
      'fanCount': fanCount,
      'releasedSongs': releasedSongs,
      'releasedAlbums': releasedAlbums,
      'relationships': relationships,
      'awards': awards,
      'weeksSinceDebut': weeksSinceDebut,
      'isRetired': isRetired,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'],
      name: map['name'],
      isPlayer: map['isPlayer'],
      primaryGenre: Genre.values.firstWhere(
        (e) => e.toString() == map['primaryGenre'],
        orElse: () => Genre.pop,
      ),
      secondaryGenre: map['secondaryGenre'] != null
          ? Genre.values.firstWhere(
              (e) => e.toString() == map['secondaryGenre'],
              orElse: () => Genre.pop,
            )
          : null,
      attributes: ArtistAttributes.fromMap(map['attributes']),
      labelTier: LabelTier.values.firstWhere(
        (e) => e.toString() == map['labelTier'],
        orElse: () => LabelTier.unsigned,
      ),
      money: map['money'] ?? 1000,
      fanCount: map['fanCount'] ?? 0,
      releasedSongs: List<String>.from(map['releasedSongs'] ?? []),
      releasedAlbums: List<String>.from(map['releasedAlbums'] ?? []),
      relationships: Map<String, int>.from(map['relationships'] ?? {}),
      awards: List<String>.from(map['awards'] ?? []),
      weeksSinceDebut: map['weeksSinceDebut'] ?? 0,
      isRetired: map['isRetired'] ?? false,
    );
  }
}
