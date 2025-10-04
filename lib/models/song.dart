import 'artist.dart';

class Song {
  final String id;
  final String title;
  final String artistId;
  final Genre genre;
  final int quality; // 0-100
  final int hypeLevel; // 0-100
  final int weeksSinceRelease;
  final int streams;
  final List<String> collaborators;
  final bool isSingle;
  final String? albumId;

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    required this.genre,
    required this.quality,
    this.hypeLevel = 0,
    this.weeksSinceRelease = 0,
    this.streams = 0,
    this.collaborators = const [],
    this.isSingle = true,
    this.albumId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artistId': artistId,
      'genre': genre.toString(),
      'quality': quality,
      'hypeLevel': hypeLevel,
      'weeksSinceRelease': weeksSinceRelease,
      'streams': streams,
      'collaborators': collaborators,
      'isSingle': isSingle,
      'albumId': albumId,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artistId: map['artistId'],
      genre: Genre.values.firstWhere(
        (e) => e.toString() == map['genre'],
        orElse: () => Genre.pop,
      ),
      quality: map['quality'],
      hypeLevel: map['hypeLevel'] ?? 0,
      weeksSinceRelease: map['weeksSinceRelease'] ?? 0,
      streams: map['streams'] ?? 0,
      collaborators: List<String>.from(map['collaborators'] ?? []),
      isSingle: map['isSingle'] ?? true,
      albumId: map['albumId'],
    );
  }
}
