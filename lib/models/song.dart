class Song {
  final String id;
  final String title;
  final String artistId;

  double totalStreams;
  double weeklyListeners;
  double? lastWeekListeners;
  int weeksSinceRelease;

  double popularityFactor; // 0..100
  double viralFactor; // 0..100
  double salesPotential; // 0..100

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    this.totalStreams = 0,
    this.weeklyListeners = 0,
    this.lastWeekListeners,
    this.weeksSinceRelease = 0,
    this.popularityFactor = 10,
    this.viralFactor = 5,
    this.salesPotential = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artistId': artistId,
      'totalStreams': totalStreams,
      'weeklyListeners': weeklyListeners,
      'lastWeekListeners': lastWeekListeners,
      'weeksSinceRelease': weeksSinceRelease,
      'popularityFactor': popularityFactor,
      'viralFactor': viralFactor,
      'salesPotential': salesPotential,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artistId: map['artistId'],
      totalStreams: map['totalStreams']?.toDouble() ?? 0.0,
      weeklyListeners: map['weeklyListeners']?.toDouble() ?? 0.0,
      lastWeekListeners: map['lastWeekListeners']?.toDouble(),
      weeksSinceRelease: map['weeksSinceRelease'] ?? 0,
      popularityFactor: map['popularityFactor']?.toDouble() ?? 10.0,
      viralFactor: map['viralFactor']?.toDouble() ?? 5.0,
      salesPotential: map['salesPotential']?.toDouble() ?? 10.0,
    );
  }
}
