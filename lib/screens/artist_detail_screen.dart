import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/game_state_service.dart';

class ArtistDetailScreen extends StatelessWidget {
  final String artistId;

  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, game, child) {
        final artist = game.getArtistById(artistId);

        if (artist == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Artist Not Found')),
            body: const Center(child: Text('Artist not found.')),
          );
        }

        final cumulativeStreams = game.getArtistCumulativeStreams(artistId);
        final artistSongs = game.worldSongs.where((song) => song.artistId == artistId).toList();

        return Scaffold(
          appBar: AppBar(title: Text(artist.name)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Popularity: ${artist.attributes['popularity']?.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 18)),
                Text('Total Streams: ${cumulativeStreams.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                const Text('Attributes:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: artist.attributes.entries.map((e) => Chip(label: Text('${e.key}: ${e.value.toStringAsFixed(0)}%'))).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Songs:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (artistSongs.isEmpty)
                  const Text('No songs released yet.')
                else
                  ...artistSongs.map((song) => ListTile(
                    title: Text(song.title),
                    subtitle: Text('Streams: ${song.totalStreams.toStringAsFixed(0)} | Weekly: ${song.weeklyListeners.toStringAsFixed(0)}'),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }
}
