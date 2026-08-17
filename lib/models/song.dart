class Song {
  final String id;
  final String title;
  final String artistId;
  String coverArt; // New field
  double lengthMinutes; // New field

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
  /// Remaining weeks a music video is boosting this song's listeners.
  int videoWeeksRemaining;
  /// Remaining weeks a playlist/radio add is boosting this song.
  int playlistWeeksRemaining;
  /// `rush` · `standard` · `polish`
  String studioFinish;
  bool ghostwritten;
  bool usesSample;
  bool sampleCleared;
  bool sampleTakedown;
  bool deluxeIssued;
  bool hasRemix;
  /// Empty unless this song is a remix of another catalog track.
  String sourceSongId;
  /// `pending` · `press` · `fans` · `skip` · empty
  String listeningParty;
  int listeningPartyWeeks;
  /// Featured / collab partners (not the primary [artistId]).
  List<String> featuredArtistIds;
  /// Demos sit in the catalog until the player releases them.
  bool released;

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    this.coverArt = 'assets/images/default_cover.png', // Default value
    this.lengthMinutes = 3.5, // Default value
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
    this.videoWeeksRemaining = 0,
    this.playlistWeeksRemaining = 0,
    this.studioFinish = 'standard',
    this.ghostwritten = false,
    this.usesSample = false,
    this.sampleCleared = false,
    this.sampleTakedown = false,
    this.deluxeIssued = false,
    this.hasRemix = false,
    this.sourceSongId = '',
    this.listeningParty = '',
    this.listeningPartyWeeks = 0,
    List<String>? featuredArtistIds,
    this.released = true,
  }) : listenerHistory = listenerHistory ?? [],
       featuredArtistIds = featuredArtistIds ?? [];

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
      'coverArt': coverArt, // Add to map
      'lengthMinutes': lengthMinutes, // Add to map
      'videoWeeksRemaining': videoWeeksRemaining,
      'playlistWeeksRemaining': playlistWeeksRemaining,
      'studioFinish': studioFinish,
      'ghostwritten': ghostwritten,
      'usesSample': usesSample,
      'sampleCleared': sampleCleared,
      'sampleTakedown': sampleTakedown,
      'deluxeIssued': deluxeIssued,
      'hasRemix': hasRemix,
      'sourceSongId': sourceSongId,
      'listeningParty': listeningParty,
      'listeningPartyWeeks': listeningPartyWeeks,
      'featuredArtistIds': featuredArtistIds,
      'released': released,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artistId: map['artistId'],
      coverArt: map['coverArt'] ?? 'assets/images/default_cover.png', // Retrieve from map
      lengthMinutes: map['lengthMinutes']?.toDouble() ?? 3.5, // Retrieve from map
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
      listenerHistory: List<double>.from(
        (map['listenerHistory'] as List? ?? const [])
            .map((e) => (e as num).toDouble()),
      ),
      videoWeeksRemaining: map['videoWeeksRemaining'] as int? ?? 0,
      playlistWeeksRemaining: map['playlistWeeksRemaining'] as int? ?? 0,
      studioFinish: map['studioFinish'] as String? ?? 'standard',
      ghostwritten: map['ghostwritten'] as bool? ?? false,
      usesSample: map['usesSample'] as bool? ?? false,
      sampleCleared: map['sampleCleared'] as bool? ?? false,
      sampleTakedown: map['sampleTakedown'] as bool? ?? false,
      deluxeIssued: map['deluxeIssued'] as bool? ?? false,
      hasRemix: map['hasRemix'] as bool? ?? false,
      sourceSongId: map['sourceSongId'] as String? ?? '',
      listeningParty: map['listeningParty'] as String? ?? '',
      listeningPartyWeeks: map['listeningPartyWeeks'] as int? ?? 0,
      featuredArtistIds: List<String>.from(map['featuredArtistIds'] as List? ?? const []),
      released: map['released'] as bool? ?? true,
    );
  }

  bool creditsArtist(String id) =>
      artistId == id || featuredArtistIds.contains(id);
}
