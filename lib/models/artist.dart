// ignore_for_file: unnecessary_this

import 'artist_appearance.dart';
import 'label_tier.dart';

class Artist {
  final String id;
  final String name;
  Map<String, double> attributes;
  List<String> awardsWon;
  ArtistAppearance appearance;
  LabelTier labelTier;

  Artist({
    required this.id,
    required this.name,
    Map<String, double>? attributes,
    List<String>? awardsWon,
    ArtistAppearance? appearance,
    this.labelTier = LabelTier.unsigned,
  }) : attributes = attributes ?? {
          'popularity': 10,
          'reputation': 10,
          'happiness': 50,
          'talent': 10,
          'controversy': 0,
          'fan_connection': 10,
        },
       this.awardsWon = awardsWon ?? [],
       this.appearance = appearance ?? ArtistAppearance.defaults;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'attributes': attributes,
      'awardsWon': awardsWon,
      'appearance': appearance.toMap(),
      'labelTier': labelTier.storageName,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'],
      name: map['name'],
      attributes: Map<String, double>.from(map['attributes'] ?? {}),
      awardsWon: List<String>.from(map['awardsWon'] ?? []),
      appearance: map['appearance'] != null
          ? ArtistAppearance.fromMap(map['appearance'] as Map<String, dynamic>)
          : ArtistAppearance.defaults,
      labelTier: LabelTierX.fromName(map['labelTier'] as String?),
    );
  }
}
