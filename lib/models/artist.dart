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

class Artist {
  final String id;
  final String name;
  Map<String, double> attributes; 
  // Example keys: 'popularity', 'reputation', 'happiness', 'talent', 'controversy', 'fan_connection'

  Artist({
    required this.id,
    required this.name,
    Map<String, double>? attributes,
  }) : attributes = attributes ?? {
          'popularity': 10,
          'reputation': 10,
          'happiness': 50,
          'talent': 10,
          'controversy': 0,
          'fan_connection': 10,
        };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'attributes': attributes,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'],
      name: map['name'],
      attributes: Map<String, double>.from(map['attributes'] ?? {}),
    );
  }
}
