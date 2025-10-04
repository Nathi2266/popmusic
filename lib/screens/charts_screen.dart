import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // Import for min and max

import '../services/game_state_service.dart';
import '../models/song.dart';
import '../models/artist.dart';
import 'artist_detail_screen.dart'; // Added import for ArtistDetailScreen

/// ChartScreen - shows top 30 songs, weekly listeners, delta, and small artist snapshot.
/// Place this file in lib/screens/chart_screen.dart and register route in your app.
class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, game, child) {
        // Ensure songs are already sorted by totalStreams descending
        final topSongs = game.getTopSongs(30);

        // Calculate biggest gainer and dropper
        Song? biggestGainer;
        Song? biggestDropper;
        int maxGain = 0;
        int maxDrop = 0;

        for (final song in topSongs) {
          if (song.lastWeekRank != null && song.lastWeekRank! > 0 && !song.isNewEntry) {
            final currentRank = topSongs.indexOf(song) + 1;
            final rankChange = song.lastWeekRank! - currentRank;

            if (rankChange > maxGain) {
              maxGain = rankChange;
              biggestGainer = song;
            }
            if (rankChange < maxDrop) {
              maxDrop = rankChange;
              biggestDropper = song;
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Top 30 — Charts'),
            centerTitle: true,
            actions: [
              // Toggle between songs and artists view
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(value: 'songs', label: Text('Songs')),
                      ButtonSegment<String>(value: 'artists', label: Text('Artists')),
                    ],
                    selected: <String>{game.chartViewMode},
                    onSelectionChanged: (Set<String> newSelection) {
                      game.chartViewMode = newSelection.first;
                    },
                  ),
                ),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: game.currentGenreFilter,
                  hint: const Text('Filter by Genre', style: TextStyle(color: Colors.white70)),
                  dropdownColor: Theme.of(context).primaryColorDark,
                  icon: const Icon(Icons.filter_list, color: Colors.white70),
                  onChanged: (String? newValue) {
                    game.currentGenreFilter = newValue;
                  },
                  items: ['All', ...game.availableGenres].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value == 'All' ? null : value,
                      child: Text(value, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(child: Text('Week ${game.weekOfMonth} • ${game.month}/${game.year}')),
                ),
              ),
            ],
          ),
          body: Builder(
            builder: (BuildContext context) {
              Widget content;
              if (game.chartViewMode == 'songs') {
                if (topSongs.isEmpty) {
                  content = const Center(child: Text('No songs on the chart yet. Release a track to populate charts.'));
                } else {
                  content = RefreshIndicator(
                    onRefresh: () async {
                      game.recalculateCharts();
                      return;
                    },
                    child: Column(
                      children: [
                        if (game.playerChartPeak != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Your Best Peak: #${game.playerChartPeak}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                          ),
                        if (biggestGainer != null || biggestDropper != null) // Only show if there's something to show
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (biggestGainer != null)
                                  Expanded(
                                    child: _buildHighlightCard(
                                      title: 'Biggest Gainer',
                                      song: biggestGainer,
                                      rankChange: maxGain,
                                      isGainer: true,
                                    ),
                                  ),
                                if (biggestGainer != null && biggestDropper != null) const SizedBox(width: 8),
                                if (biggestDropper != null)
                                  Expanded(
                                    child: _buildHighlightCard(
                                      title: 'Biggest Dropper',
                                      song: biggestDropper,
                                      rankChange: maxDrop,
                                      isGainer: false,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: topSongs.length,
                            itemBuilder: (context, idx) {
                              final entry = topSongs[idx];
                              final rank = idx + 1;
                              final delta = entry.weeklyListeners - (entry.lastWeekListeners ?? 0);
                              final deltaText = delta >= 0 ? '+${delta.toInt()}' : '${delta.toInt()}';
                              final artist = game.getArtistById(entry.artistId);

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                color: entry.artistId == game.player?.id ? Colors.blue.shade900 : null, // Highlight player songs
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 22,
                                    child: Text('#$rank'),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      if (entry.isNewEntry) ...[
                                        const SizedBox(width: 8),
                                        const Chip(
                                          label: Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10)),
                                          backgroundColor: Colors.green,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                      if (entry.viralFactor > 70) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 20), // "Hot" icon
                                      ],
                                      if (rank == 1) ...[
                                        const SizedBox(width: 8),
                                        const Chip(
                                          label: Text('#1 HIT', style: TextStyle(color: Colors.white, fontSize: 10)),
                                          backgroundColor: Colors.amber, // Gold color
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      _buildRankChangeIndicator(rank, entry.lastWeekRank),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4), // Reduced height
                                      Text('Artist: ${artist?.name ?? 'Unknown'} (Pop: ${artist?.attributes['popularity']?.toStringAsFixed(0)}%)'), // Added popularity
                                      const SizedBox(height: 2), // Reduced height
                                      Text(
                                        'Streams: ${entry.totalStreams.toStringAsFixed(0)} • Weekly: ${entry.weeklyListeners.toStringAsFixed(0)} (${_getWeeklyListenerChangePercentage(entry)}) ',
                                        style: const TextStyle(fontSize: 12), // Adjusted font size
                                      ),
                                      Text(
                                        'Total Artist Streams: ${game.getArtistCumulativeStreams(entry.artistId).toStringAsFixed(0)} • Label: ${_getArtistLabel(artist)}',
                                        style: const TextStyle(fontSize: 12, color: Colors.white54), // New line for artist cumulative streams and label
                                      ),
                                      const SizedBox(height: 4), // Reduced height
                                      SizedBox(
                                        height: 30,
                                        child: SparklineChart(data: entry.listenerHistory), // Sparkline chart
                                      ),
                                      const SizedBox(height: 4), // Reduced height
                                      LinearProgressIndicator(
                                        value: (entry.viralFactor.clamp(0.0, 100.0) / 100),
                                        minHeight: 6,
                                        backgroundColor: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                  trailing: ConstrainedBox( // Wrap trailing Column with ConstrainedBox
                                    constraints: const BoxConstraints(maxHeight: 50), // Set a max height
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(deltaText, style: TextStyle(color: delta >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                        // const SizedBox(height: 6), // Removed to save space
                                        ElevatedButton(
                                          onPressed: () {
                                            // Open a small detail modal for this track
                                            showDialog(
                                              context: context,
                                              builder: (_) => SongDetailDialog(song: entry, artist: artist, game: game),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2)), // Further reduced vertical padding
                                          child: const Text('Details'), // Moved child to the end
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              } else { // chartViewMode == 'artists'
                if (game.worldArtists.isEmpty) {
                  content = const Center(child: Text('No artists yet.'));
                } else {
                  content = RefreshIndicator(
                    onRefresh: () async {
                      game.recalculateCharts(); // Recalculate will also update artist data
                      return;
                    },
                    child: ListView.builder(
                      itemCount: game.getTopArtists(30).length, // Show top 30 artists
                      itemBuilder: (context, idx) {
                        final artist = game.getTopArtists(30)[idx];
                        final cumulativeStreams = game.getArtistCumulativeStreams(artist.id);
                        final label = _getArtistLabel(artist);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              child: Text('#${idx + 1}'),
                            ),
                            title: Text(artist.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cumulative Streams: ${cumulativeStreams.toStringAsFixed(0)}'),
                                Text('Popularity: ${artist.attributes['popularity']?.toStringAsFixed(0)}% • Label: $label'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtistDetailScreen(artistId: artist.id),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2)),
                              child: const Text('View Artist'),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }
              return content;
            },
          ),
        );
      },
    );
  }

  String _getArtistLabel(Artist? artist) {
    if (artist == null) return 'Unknown';
    final popularity = artist.attributes['popularity'] ?? 0;
    if (popularity >= 80) {
      return 'Superstar';
    } else if (popularity >= 50) {
      return 'Major';
    } else if (popularity >= 20) {
      return 'Indie';
    } else {
      return 'Underground';
    }
  }

  String _getWeeklyListenerChangePercentage(Song song) {
    if (song.lastWeekListeners == null || song.lastWeekListeners == 0) {
      return '--%';
    }
    final change = song.weeklyListeners - song.lastWeekListeners!;
    final percentage = (change / song.lastWeekListeners!) * 100;
    if (percentage >= 0) {
      return '+${percentage.toStringAsFixed(1)}%';
    } else {
      return '${percentage.toStringAsFixed(1)}%';
    }
  }

  Widget _buildHighlightCard({required String title, required Song song, required int rankChange, required bool isGainer}) {
    return Card(
      color: isGainer ? Colors.green.shade800 : Colors.red.shade800,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 4),
            Text(song.title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            Text('Rank change: ${isGainer ? '+' : ''}${rankChange.abs()}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildRankChangeIndicator(int currentRank, int? lastWeekRank) {
    if (lastWeekRank == null || currentRank == lastWeekRank) {
      return const SizedBox.shrink(); // No change or new entry, no arrow
    }

    final delta = lastWeekRank - currentRank;
    IconData icon;
    Color color;

    if (delta > 0) {
      icon = Icons.arrow_upward;
      color = Colors.green;
    } else {
      icon = Icons.arrow_downward;
      color = Colors.red;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        Text(delta.abs().toString(), style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class SparklineChart extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final double strokeWidth;

  const SparklineChart({
    super.key,
    required this.data,
    this.lineColor = Colors.blue,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: _SparklineChartPainter(data, lineColor, strokeWidth),
      child: Container(),
    );
  }
}

class _SparklineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final double strokeWidth;

  _SparklineChartPainter(this.data, this.lineColor, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double xStep = size.width / (data.length - 1);

    // Find min and max values for scaling
    final double minValue = data.reduce(min);
    final double maxValue = data.reduce(max);
    final double range = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - ((data[i] - minValue) / range) * size.height; // Scale y to fit height

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Small popup dialog with deeper song metrics and contributing artist attributes.
class SongDetailDialog extends StatelessWidget {
  final Song song;
  final Artist? artist;
  final GameStateService game;

  const SongDetailDialog({super.key, required this.song, required this.artist, required this.game}) : super();

  @override
  Widget build(BuildContext context) {
    final lastWeek = song.lastWeekListeners ?? 0;
    final delta = song.weeklyListeners - lastWeek;
    return AlertDialog(
      title: Text('${song.title} — ${artist?.name ?? 'Unknown'}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total streams: ${song.totalStreams.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Text('Weekly listeners: ${song.weeklyListeners.toStringAsFixed(0)} (${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)})'),
            const SizedBox(height: 12),
            // ignore: prefer_const_constructors
            Text('Song metrics:'),
            const SizedBox(height: 6),
            _metricRow('Popularity factor', song.popularityFactor),
            _metricRow('Viral factor', song.viralFactor),
            _metricRow('Sales potential', song.salesPotential),
            _metricRow('Recency (weeks since release)', song.weeksSinceRelease.toDouble()),
            const SizedBox(height: 12),
            if (artist != null) ...[
              const Text('Artist snapshot:'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: artist!.attributes.entries.map((e) => Chip(label: Text('${e.key}: ${e.value.toStringAsFixed(0)}%'))).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }

  Widget _metricRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(width: 80, child: Text(value.toStringAsFixed(1), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
