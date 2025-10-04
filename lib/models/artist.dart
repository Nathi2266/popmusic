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
  String name;
  @HiveField(2)
  Map<String, double> attributes;

  // New fields for artist performance tracking
  @HiveField(3)
  double cumulativeStreams; // Total streams across all songs
  @HiveField(4)
  String labelTier; // E.g., "Underground", "Indie", "Major"

  Artist({
    required this.id,
    required this.name,
    required this.attributes,
    this.cumulativeStreams = 0.0,
    this.labelTier = "Underground", // Default label tier
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'attributes': attributes,
      // Add new fields to map
      'cumulativeStreams': cumulativeStreams,
      'labelTier': labelTier,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'],
      name: map['name'],
      attributes: Map<String, double>.from(map['attributes'] ?? {}),
      // Retrieve new fields from map
      cumulativeStreams: map['cumulativeStreams']?.toDouble() ?? 0.0,
      labelTier: map['labelTier'] ?? "Underground",
    );
  }
}
