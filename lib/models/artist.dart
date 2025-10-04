import 'package:hive/hive.dart';

part 'artist.g.dart';

// ignore_for_file: unnecessary_this

// Removed ArtistAttributes import
// import 'artist_attributes.dart';

// Removed Genre enum
// enum Genre {
//   pop,
//   rock,
//   hiphop,
//   rnb,
//   electronic,
//   indie,
//   country,
//   jazz,
//   latin,
//   kpop
// }

// Removed LabelTier enum
// enum LabelTier {
//   unsigned,
//   indie,
//   major,
//   superstar
// }

@HiveType(typeId: 0)
class Artist {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  Map<String, double> attributes;
  @HiveField(3)
  List<String> awardsWon; // Added to track awards won
  @HiveField(4)
  String labelTier; // Added to track the artist's label tier
  // Example keys: 'popularity', 'reputation', 'happiness', 'talent', 'controversy', 'fan_connection'

  Artist({
    required this.id,
    required this.name,
    Map<String, double>? attributes,
    List<String>? awardsWon,
    this.labelTier = 'Unsigned', // Initialize labelTier
  }) : attributes = attributes ?? {
          'popularity': 10,
          'reputation': 10,
          'happiness': 50,
          'talent': 10,
          'controversy': 0,
          'fan_connection': 10,
        },
       this.awardsWon = awardsWon ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'attributes': attributes,
      'awardsWon': awardsWon,
      'labelTier': labelTier,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'],
      name: map['name'],
      attributes: Map<String, double>.from(map['attributes'] ?? {}),
      awardsWon: List<String>.from(map['awardsWon'] ?? []),
      labelTier: map['labelTier'] ?? 'Unsigned',
    );
  }
}
