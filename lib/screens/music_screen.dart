import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import 'create_song_screen.dart';
import '../models/song.dart';
import '../models/studio_finish.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../utils/animations.dart';
import '../utils/toast_service.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final player = gameState.player;
        final playerSongs = gameState.worldSongs // Changed from allSongs to worldSongs
            .where((song) => song.artistId == player?.id)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Music'),
            backgroundColor: const Color(0xFF16213e),
          ),
          body: Column(
            children: [
              // Create Music Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateSongScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 28),
                    label: const Text(
                      'CREATE NEW SONG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe94560),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAlbumDialog(context, gameState),
                    icon: const Icon(Icons.album),
                    label: Text(
                      'COMPILE ALBUM (${gameState.playerAlbums.length})',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFFFD700)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Songs List
              Expanded(
                child: player == null
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return const ShimmerSongCard();
                        },
                      )
                    : playerSongs.isEmpty
                        ? EmptyState(
                            icon: Icons.music_note,
                            title: 'No songs yet',
                            subtitle: 'Create your first hit and start your music career!',
                            actionLabel: 'Create Song',
                            onAction: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateSongScreen(),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: playerSongs.length,
                            itemBuilder: (context, index) {
                              final song = playerSongs[index];
                              return AppAnimations.fadeIn(
                                duration: Duration(milliseconds: 300 + (index * 50)),
                                child: _SongCard(song: song),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _showAlbumDialog(BuildContext context, GameStateService game) {
  final songs = game.playerSongs;
  final selected = <String>{};
  final titleController = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            backgroundColor: const Color(0xFF16213e),
            title: const Text('Compile Album',
                style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Album title',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pick 3–8 tracks (\$1500)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: songs.map((s) {
                        final onAlbum = game.isSongOnAlbum(s.id);
                        return CheckboxListTile(
                          value: selected.contains(s.id),
                          onChanged: onAlbum
                              ? null
                              : (v) {
                                  setLocal(() {
                                    if (v == true) {
                                      selected.add(s.id);
                                    } else {
                                      selected.remove(s.id);
                                    }
                                  });
                                },
                          title: Text(
                            onAlbum ? '${s.title} (on album)' : s.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final err = game.compileAlbum(
                    titleController.text,
                    selected.toList(),
                  );
                  Navigator.pop(ctx);
                  if (err != null) {
                    ToastService().showError(err);
                  } else {
                    ToastService().showSuccess('Album released!');
                  }
                },
                child: const Text('Release'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _SongCard extends StatelessWidget {
  final Song song;

  const _SongCard({required this.song});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSongSheet(context, song),
      child: GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFe94560),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${song.genre} · Weeks: ${song.weeksSinceRelease} • Weekly: ${song.weeklyListeners.toStringAsFixed(0)}${song.videoWeeksRemaining > 0 ? ' · MV ${song.videoWeeksRemaining}w' : ''}${song.playlistWeeksRemaining > 0 ? ' · PL ${song.playlistWeeksRemaining}w' : ''}${song.weeksSinceRelease <= 1 ? ' · DEBUT' : ''}${song.deluxeIssued ? ' · DELUXE' : ''}${song.sourceSongId.isNotEmpty ? ' · REMIX' : ''}${song.listeningPartyWeeks > 0 ? ' · PARTY' : ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.show_chart,
                          size: 16,
                          color: Colors.lightGreenAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${song.popularityFactor.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.lightGreenAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Streams: ${song.totalStreams.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (song.viralFactor.clamp(0.0, 100.0) / 100), // Use viralFactor
              backgroundColor: const Color(0xFF1a1a2e),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFe94560),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Viral Factor: ${song.viralFactor.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
    ),
    );
  }
}

void _showSongSheet(BuildContext context, Song song) {
  final game = Provider.of<GameStateService>(context, listen: false);
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(song.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              '${song.genre} · ${song.lengthMinutes.toStringAsFixed(1)} min',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Weekly ${song.weeklyListeners.toStringAsFixed(0)} · Total ${song.totalStreams.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Quality ${song.popularityFactor.toStringAsFixed(0)} · Viral ${song.viralFactor.toStringAsFixed(0)} · ${StudioFinishX.fromName(song.studioFinish).displayName}${song.ghostwritten ? ' · Ghostwritten' : ''}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (game.inDebutWindow(song))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Debut window — pitch radio this week to stack the add',
                  style: TextStyle(color: Color(0xFFFFD54F)),
                ),
              ),
            if (game.isSongOnAlbum(song.id))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('On an album',
                    style: TextStyle(color: Color(0xFFFFD700))),
              ),
            if (song.videoWeeksRemaining > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Video boosting · ${song.videoWeeksRemaining}w left',
                  style: const TextStyle(color: Color(0xFF26C6DA)),
                ),
              ),
            if (song.playlistWeeksRemaining > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'On playlist · ${song.playlistWeeksRemaining}w left',
                  style: const TextStyle(color: Color(0xFFFFD54F)),
                ),
              ),
            if (song.listeningPartyWeeks > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  song.listeningParty == 'fans'
                      ? 'Fan party heat · ${song.listeningPartyWeeks}w'
                      : 'Press party heat · ${song.listeningPartyWeeks}w',
                  style: const TextStyle(color: Color(0xFFFF8A65)),
                ),
              )
            else if (song.listeningParty == 'pending')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Listening party still open this debut window',
                  style: TextStyle(color: Color(0xFFFF8A65)),
                ),
              ),
            if (song.sampleTakedown)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Taken down — uncleared sample',
                    style: TextStyle(color: Color(0xFFE94560))),
              )
            else if (song.usesSample)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  song.sampleCleared
                      ? 'Sample cleared'
                      : 'Uncleared sample — takedown risk',
                  style: TextStyle(
                    color: song.sampleCleared
                        ? const Color(0xFF81D4FA)
                        : const Color(0xFFFFB74D),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (song.listeningParty == 'pending') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF16213e),
                        title: const Text('Listening Party',
                            style: TextStyle(color: Colors.white)),
                        content: Text(
                          'Host a room for "${song.title}"?',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          for (final pick in [
                            'Invite Press',
                            'Invite Fans',
                            'Quiet Drop',
                          ])
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                                final err =
                                    game.runListeningParty(song.id, pick);
                                if (err != null) {
                                  ToastService().showError(err);
                                } else {
                                  ToastService().showSuccess(pick);
                                }
                              },
                              child: Text(pick),
                            ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.celebration),
                  label: const Text('Throw listening party'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: song.videoWeeksRemaining > 0
                    ? null
                    : () {
                        Navigator.pop(context);
                        final err = game.shootMusicVideo(song.id);
                        if (err != null) {
                          ToastService().showError(err);
                        } else {
                          ToastService().showSuccess(
                            'Video out — +32% streams for ${game.musicVideoWeeks()} weeks',
                          );
                        }
                      },
                icon: const Icon(Icons.videocam),
                label: Text(
                  song.videoWeeksRemaining > 0
                      ? 'Video already circulating'
                      : 'Shoot video (\$${game.musicVideoCost().toStringAsFixed(0)})',
                ),
              ),
            ),
            if (song.deluxeIssued)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Deluxe edition already out',
                  style: TextStyle(color: Color(0xFFCE93D8)),
                ),
              ),
            if (song.sourceSongId.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Remix — new chart entry from a catalog track',
                  style: TextStyle(color: Color(0xFF81D4FA)),
                ),
              ),
            if (game.canDeluxeReissue(song) || game.canDropRemix(song)) ...[
              const SizedBox(height: 8),
              if (game.canDeluxeReissue(song))
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final err = game.reissueDeluxe(song.id);
                      if (err != null) {
                        ToastService().showError(err);
                      } else {
                        ToastService().showSuccess(
                          'Deluxe is out — "${song.title}" is back in the debut window.',
                        );
                      }
                    },
                    icon: const Icon(Icons.album),
                    label: Text(
                      'Deluxe reissue (\$${game.deluxeReissueCost().toStringAsFixed(0)})',
                    ),
                  ),
                ),
              if (game.canDropRemix(song)) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final err = game.dropRemix(song.id);
                      if (err != null) {
                        ToastService().showError(err);
                      } else {
                        ToastService().showSuccess(
                          'Remix dropped — "${song.title} (Remix)" is a new debut.',
                        );
                      }
                    },
                    icon: const Icon(Icons.replay),
                    label: Text(
                      'Drop remix (\$${game.remixDropCost().toStringAsFixed(0)})',
                    ),
                  ),
                ),
              ],
            ],
            if (song.usesSample &&
                !song.sampleCleared &&
                !song.sampleTakedown) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    final err = game.clearSongSample(song.id);
                    if (err != null) {
                      ToastService().showError(err);
                    } else {
                      ToastService().showSuccess('Sample cleared.');
                    }
                  },
                  icon: const Icon(Icons.gavel),
                  label: Text(
                    'Clear sample (\$${game.sampleClearanceFee().toStringAsFixed(0)})',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  final err = game.retirePlayerSong(song.id);
                  if (err != null) {
                    ToastService().showError(err);
                  } else {
                    ToastService().showSuccess('Retired "${song.title}"');
                  }
                },
                child: const Text('Retire from rotation'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
