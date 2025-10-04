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

  @HiveField(7)
  double popularityFactor; // 0..100
  @HiveField(8)
  double viralFactor; // 0..100
  @HiveField(9)
  double salesPotential; // 0..100

  // New fields for charts and performance tracking
  @HiveField(10)
  int? lastWeekRank;
  @HiveField(11)
  int? currentRank;
  @HiveField(12)
  int? peakRank;
  @HiveField(13)
  int weeksOnChart;
  @HiveField(14)
  bool isNewEntry;
  @HiveField(15)
  bool isViral;
  @HiveField(16)
  List<String> awards;
  @HiveField(17)
  List<double> listenerHistory; // For sparkline graph

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
    // Initialize new fields
    this.lastWeekRank,
    this.currentRank,
    this.peakRank,
    this.weeksOnChart = 0,
    this.isNewEntry = true, // Default to true, will be updated by chart logic
    this.isViral = false,
    this.awards = const [],
    this.listenerHistory = const [],
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
      // Add new fields to map
      'lastWeekRank': lastWeekRank,
      'currentRank': currentRank,
      'peakRank': peakRank,
      'weeksOnChart': weeksOnChart,
      'isNewEntry': isNewEntry,
      'isViral': isViral,
      'awards': awards,
      'listenerHistory': listenerHistory,
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
      // Retrieve new fields from map
      lastWeekRank: map['lastWeekRank'],
      currentRank: map['currentRank'],
      peakRank: map['peakRank'],
      weeksOnChart: map['weeksOnChart'] ?? 0,
      isNewEntry: map['isNewEntry'] ?? true,
      isViral: map['isViral'] ?? false,
      awards: List<String>.from(map['awards'] ?? []),
      listenerHistory: List<double>.from(map['listenerHistory'] ?? []),
    );
  }
}
