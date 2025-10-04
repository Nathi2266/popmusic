class Song {
  final String id;
  final String title;
  final String artistId;

  double totalStreams;
  double weeklyListeners;
  double? lastWeekListeners;
  int weeksSinceRelease;
  int? lastWeekRank; // Added to track rank from the previous week
  bool isNewEntry; // Added to indicate if the song is a new entry to the charts

  double popularityFactor; // 0..100
  double viralFactor; // 0..100
  double salesPotential; // 0..100
  String genre; // Added to specify the song's genre
  List<double> listenerHistory; // Stores weekly listener counts for trend graphs

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    this.totalStreams = 0,
    this.weeklyListeners = 0,
    this.lastWeekListeners,
    this.weeksSinceRelease = 0,
    this.lastWeekRank,
    this.isNewEntry = true,
    this.popularityFactor = 10,
    this.viralFactor = 5,
    this.salesPotential = 10,
    this.genre = 'Pop',
    List<double>? listenerHistory,
  }) : listenerHistory = listenerHistory ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artistId': artistId,
      'totalStreams': totalStreams,
      'weeklyListeners': weeklyListeners,
      'lastWeekListeners': lastWeekListeners,
      'weeksSinceRelease': weeksSinceRelease,
      'lastWeekRank': lastWeekRank, // Add to map
      'isNewEntry': isNewEntry, // Add to map
      'popularityFactor': popularityFactor,
      'viralFactor': viralFactor,
      'salesPotential': salesPotential,
      'genre': genre,
      'listenerHistory': listenerHistory, // Add to map
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
      lastWeekRank: map['lastWeekRank']?.toInt(), // Retrieve from map
      isNewEntry: map['isNewEntry'] ?? true, // Retrieve from map, default to true
      popularityFactor: map['popularityFactor']?.toDouble() ?? 10.0,
      viralFactor: map['viralFactor']?.toDouble() ?? 5.0,
      salesPotential: map['salesPotential']?.toDouble() ?? 10.0,
      genre: map['genre'] ?? 'Pop',
      listenerHistory: List<double>.from(map['listenerHistory'] ?? []), // Retrieve from map
    );
  }
}
