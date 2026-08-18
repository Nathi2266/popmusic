import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import 'create_song_screen.dart';
import '../models/song.dart';
import '../models/studio_finish.dart';
import '../models/label_tier.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../utils/animations.dart';
import '../utils/toast_service.dart';
import '../widgets/game_shell.dart';
import 'labels_screen.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final player = gameState.player;
        final playerSongs = gameState.playerSongs;
        final roster = gameState.activeRoster;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Music'),
            leading: const GameDrawerButton(),
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
                    icon: Icon(Icons.add, size: 28),
                    label: Text(
                      'CREATE NEW SONG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                    icon: Icon(Icons.album),
                    label: Text(
                      'COMPILE ALBUM (${gameState.playerAlbums.length})',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      side: const BorderSide(color: Color(0xFFFFD700)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: player == null
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return const ShimmerSongCard();
                        },
                      )
                    : playerSongs.isEmpty && roster.isEmpty
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
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              _CatalogSection(
                                title: player.name,
                                subtitle: 'You',
                                songs: gameState.catalogSongsFor(player.id),
                              ),
                              for (final signing in roster)
                                _CatalogSection(
                                  title: gameState.getArtistById(signing.artistId)?.name ??
                                      'Signed artist',
                                  subtitle:
                                      '${signing.deal.displayName} · you keep ${(signing.playerCut * 100).toStringAsFixed(0)}%',
                                  songs: gameState.catalogSongsFor(signing.artistId),
                                  artistId: signing.artistId,
                                ),
                            ],
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
  final eligible = game.albumEligibleSongs;
  final playerId = game.player?.id;
  final selected = <String>{};
  final titleController = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          Widget trackTile(Song s) {
            final onAlbum = game.isSongOnAlbum(s.id);
            final artist = game.getArtistById(s.artistId);
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
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              subtitle: Text(
                artist?.name ?? 'Unknown artist',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                  fontSize: 12,
                ),
              ),
            );
          }

          final yours = eligible.where((s) => s.artistId == playerId).toList();
          final rosterTracks = eligible.where((s) => s.artistId != playerId).toList();
          final byArtist = <String, List<Song>>{};
          for (final song in rosterTracks) {
            byArtist.putIfAbsent(song.artistId, () => []).add(song);
          }

          final tiles = <Widget>[];
          void header(String label) {
            tiles.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            );
          }

          if (yours.isNotEmpty) {
            header('Your tracks');
            tiles.addAll(yours.map(trackTile));
          }
          for (final entry in byArtist.entries) {
            final name = game.getArtistById(entry.key)?.name ?? 'Signed artist';
            header('$name (signed)');
            tiles.addAll(entry.value.map(trackTile));
          }

          return AlertDialog(
            title: Text('Compile Album',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            content: SizedBox(
              width: 360,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Album title',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pick 3–8 tracks (\$1500). Include your songs and tracks from artists you signed.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: eligible.isEmpty
                        ? Center(
                            child: Text(
                              'Write songs or sign an artist first.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                              ),
                            ),
                          )
                        : ListView(children: tiles),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel'),
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
                child: Text('Release'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _CatalogSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Song> songs;
  final String? artistId;

  const _CatalogSection({
    required this.title,
    required this.subtitle,
    required this.songs,
    this.artistId,
  });

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateService>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 12)),
        if (artistId != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final err = game.commissionRosterDemo(artistId!);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess('Demo ready to release');
                }
              },
              icon: Icon(Icons.mic_none),
              label: Text('Write a demo (\$400)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (songs.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'No tracks in this catalog yet.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
            ),
          )
        else
          ...songs.asMap().entries.map(
            (entry) => AppAnimations.fadeIn(
              duration: Duration(milliseconds: 220 + (entry.key * 40)),
              child: _SongCard(song: entry.value),
            ),
          ),
      ],
    );
  }
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
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Theme.of(context).colorScheme.onSurface,
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
                        style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Consumer<GameStateService>(
                        builder: (context, game, _) {
                          final demo = song.released ? '' : ' · DEMO';
                          return Text(
                            '${game.songCredit(song)} · ${song.genre} · Weeks: ${song.weeksSinceRelease} • Weekly: ${song.weeklyListeners.toStringAsFixed(0)}${song.videoWeeksRemaining > 0 ? ' · MV ${song.videoWeeksRemaining}w' : ''}${song.playlistWeeksRemaining > 0 ? ' · PL ${song.playlistWeeksRemaining}w' : ''}${song.released && song.weeksSinceRelease <= 1 ? ' · DEBUT' : ''}${song.deluxeIssued ? ' · DELUXE' : ''}${song.sourceSongId.isNotEmpty ? ' · REMIX' : ''}${song.listeningPartyWeeks > 0 ? ' · PARTY' : ''}$demo',
                            style: TextStyle(
                              color: song.released
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.72)
                                  : const Color(0xFFFFD700),
                              fontSize: 13,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 16,
                          color: Colors.lightGreenAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${song.popularityFactor.toStringAsFixed(0)}%',
                          style: TextStyle(
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Viral Factor: ${song.viralFactor.toStringAsFixed(1)}%',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
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
        builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(song.title,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              game.songCredit(song),
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
            const SizedBox(height: 8),
            Text(
              song.released
                  ? '${song.genre} · ${song.lengthMinutes.toStringAsFixed(1)} min'
                  : 'Unreleased demo · ${song.genre}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72)),
            ),
            Text(
              'Weekly ${song.weeklyListeners.toStringAsFixed(0)} · Total ${song.totalStreams.toStringAsFixed(0)}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72)),
            ),
            Text(
              'Quality ${song.popularityFactor.toStringAsFixed(0)} · Viral ${song.viralFactor.toStringAsFixed(0)} · ${StudioFinishX.fromName(song.studioFinish).displayName}${song.ghostwritten ? ' · Ghostwritten' : ''}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72)),
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
                  style: TextStyle(color: Color(0xFF26C6DA)),
                ),
              ),
            if (song.playlistWeeksRemaining > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'On playlist · ${song.playlistWeeksRemaining}w left',
                  style: TextStyle(color: Color(0xFFFFD54F)),
                ),
              ),
            if (song.listeningPartyWeeks > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  song.listeningParty == 'fans'
                      ? 'Fan party heat · ${song.listeningPartyWeeks}w'
                      : 'Press party heat · ${song.listeningPartyWeeks}w',
                  style: TextStyle(color: Color(0xFFFF8A65)),
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
            if (!song.released) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    final err = game.releaseRosterSong(song.id);
                    if (err != null) {
                      ToastService().showError(err);
                    } else {
                      ToastService().showSuccess('Released "${song.title}"');
                    }
                  },
                  icon: Icon(Icons.publish),
                  label: Text('Release this demo (\$350)'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (song.released && song.artistId == game.player?.id) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LabelsScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.business),
                  label: Text('Submit to a record label'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (song.listeningParty == 'pending') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => AlertDialog(
                                                title: Text('Listening Party',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        content: Text(
                          'Host a room for "${song.title}"?',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72)),
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
                  icon: Icon(Icons.celebration),
                  label: Text('Throw listening party'),
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
                icon: Icon(Icons.videocam),
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
                    icon: Icon(Icons.album),
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
                    icon: Icon(Icons.replay),
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
                  icon: Icon(Icons.gavel),
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
                child: Text('Retire from rotation'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
