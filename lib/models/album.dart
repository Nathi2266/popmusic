class Album {
  final String id;
  final String title;
  final String artistId;
  final List<String> songIds;
  final int releasedWeek;
  final int releasedMonth;
  final int releasedYear;

  Album({
    required this.id,
    required this.title,
    required this.artistId,
    required this.songIds,
    required this.releasedWeek,
    required this.releasedMonth,
    required this.releasedYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artistId': artistId,
      'songIds': songIds,
      'releasedWeek': releasedWeek,
      'releasedMonth': releasedMonth,
      'releasedYear': releasedYear,
    };
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'] as String,
      title: map['title'] as String,
      artistId: map['artistId'] as String,
      songIds: List<String>.from(map['songIds'] as List? ?? const []),
      releasedWeek: map['releasedWeek'] as int? ?? 1,
      releasedMonth: map['releasedMonth'] as int? ?? 1,
      releasedYear: map['releasedYear'] as int? ?? 2025,
    );
  }
}
