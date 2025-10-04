import 'package:hive/hive.dart';

part 'song.g.dart';

@HiveType(typeId: 1)
class Song {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String artistId;

  @HiveField(3)
  double totalStreams;
  @HiveField(4)
  double weeklyListeners;
  @HiveField(5)
  double? lastWeekListeners;
  @HiveField(6)
  int weeksSinceRelease;
  @HiveField(10)
  int? lastWeekRank; // Added to track rank from the previous week
  @HiveField(11)
  int? currentRank; // New: Current rank on the chart
  @HiveField(12)
  int? peakRank; // New: Highest rank achieved
  @HiveField(13)
  int weeksOnChart; // New: Number of weeks on chart
  @HiveField(14)
  bool isNewEntry; // Added to indicate if the song is a new entry to the charts
  @HiveField(15)
  bool isViral; // New: Indicates if the song is currently viral

  @HiveField(7)
  double popularityFactor; // 0..100
  @HiveField(8)
  double viralFactor; // 0..100
  @HiveField(9)
  double salesPotential; // 0..100
  @HiveField(16)
  String genre; // Added to specify the song's genre
  @HiveField(17)
  List<double> listenerHistory; // Stores weekly listener counts for trend graphs
  @HiveField(18)
  List<String> awards; // New: Awards won by the song

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    this.totalStreams = 0,
    this.weeklyListeners = 0,
    this.lastWeekListeners,
    this.weeksSinceRelease = 0,
    this.lastWeekRank,
    this.currentRank,
    this.peakRank,
    this.weeksOnChart = 0,
    this.isNewEntry = true,
    this.isViral = false,
    this.popularityFactor = 10,
    this.viralFactor = 5,
    this.salesPotential = 10,
    this.genre = 'Pop',
    List<double>? listenerHistory,
    List<String>? awards,
  }) : listenerHistory = listenerHistory ?? [],
       awards = awards ?? [];

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
      'currentRank': currentRank,
      'peakRank': peakRank,
      'weeksOnChart': weeksOnChart,
      'isNewEntry': isNewEntry, // Add to map
      'isViral': isViral,
      'popularityFactor': popularityFactor,
      'viralFactor': viralFactor,
      'salesPotential': salesPotential,
      'genre': genre,
      'listenerHistory': listenerHistory, // Add to map
      'awards': awards,
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
      currentRank: map['currentRank']?.toInt(),
      peakRank: map['peakRank']?.toInt(),
      weeksOnChart: map['weeksOnChart'] ?? 0,
      isNewEntry: map['isNewEntry'] ?? true, // Retrieve from map, default to true
      isViral: map['isViral'] ?? false,
      popularityFactor: map['popularityFactor']?.toDouble() ?? 10.0,
      viralFactor: map['viralFactor']?.toDouble() ?? 5.0,
      salesPotential: map['salesPotential']?.toDouble() ?? 10.0,
      genre: map['genre'] ?? 'Pop',
      listenerHistory: List<double>.from(map['listenerHistory'] ?? []),
      awards: List<String>.from(map['awards'] ?? []),
    );
  }
}
