import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/game_state_service.dart';
import '../models/song.dart';
import '../models/artist.dart';

/// ChartScreen - shows top 30 songs, weekly listeners, delta, and small artist snapshot.
/// Place this file in lib/screens/chart_screen.dart and register route in your app.
class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateService>(context);
    // Ensure songs are already sorted by totalStreams descending
    final topSongs = game.getTopSongs(30);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top 30 — Charts'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('Week ${game.weekOfMonth} • ${game.month}/${game.year}')),
          ),
        ],
      ),
      body: topSongs.isEmpty
          ? const Center(child: Text('No songs on the chart yet. Release a track to populate charts.'))
          : RefreshIndicator(
              onRefresh: () async {
                // Force update (safe because provider will notify)
                game.recalculateCharts();
                return;
              },
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
                    child: ListTile( // Removed IntrinsicHeight wrapper
                      leading: CircleAvatar(
                        radius: 22,
                        child: Text('#$rank'), // Moved child to the end
                      ),
                      title: Text(entry.title.replaceAll("'s New Track", ""), style: const TextStyle(fontWeight: FontWeight.bold)), // Removed "'s New Track" from title
                      subtitle: Column( // Removed Expanded from here
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4), // Reduced height
                          Text('Artist: ${artist?.name ?? 'Unknown'}'),
                          const SizedBox(height: 2), // Reduced height
                          Row( // Wrap streams and delta in a Row
                            children: [
                              Flexible( // Use Flexible instead of Expanded for streams text
                                child: Text('Streams: ${entry.totalStreams.toStringAsFixed(0)} • Weekly: ${entry.weeklyListeners.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10)), // Reduced font size
                              ),
                              const SizedBox(width: 4.0), // Add a small space between the two Flexible widgets
                              if (delta != 0) // Only show delta if it's not zero
                                Flexible( // Use Flexible instead of Expanded for deltaText
                                  child: Text( // Removed Padding
                                    deltaText, 
                                    style: TextStyle(color: delta >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 10), // Keep font size small
                                    textAlign: TextAlign.right, // Align text to the right
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4), // Reduced height
                          LinearProgressIndicator(
                            value: (entry.viralFactor.clamp(0.0, 100.0) / 100),
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                          ),
                        ],
                      ),
                      trailing: SizedBox( // Wrap button in a SizedBox to control height
                        height: 25, // Explicitly set a small height
                        child: ElevatedButton(
                          onPressed: () {
                            // Open a small detail modal for this track
                            showDialog(
                              context: context,
                              builder: (_) => SongDetailDialog(song: entry, artist: artist, game: game),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // Set padding to zero
                            visualDensity: VisualDensity.compact, // Make the button more compact
                          ),
                          child: const Text('Details', style: TextStyle(fontSize: 10)), // Reduced button text font size to 10
                        ),
                      ), // Only ElevatedButton in trailing
                    ),
                  );
                },
              ),
            ),
    );
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
