class SongSummary {
  final String title;
  final String artistName;
  double streams; // simplified metric
  SongSummary({required this.title, required this.artistName, required this.streams});
}

class ArtistActivity {
  final String artistName;
  final String activity; // e.g. "Released single", "Went on tour", "Scandal"
  ArtistActivity({required this.artistName, required this.activity});
}
