import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/game_state_service.dart';
import '../data/record_labels.dart';
import '../utils/toast_service.dart';
import '../widgets/artist_character_avatar.dart';
import 'sign_contract_screen.dart';
import 'roster_artist_style_screen.dart';

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
            appBar: AppBar(title: Text('Artist Not Found')),
            body: const Center(child: Text('Artist not found.')),
          );
        }

        final cumulativeStreams = game.getArtistCumulativeStreams(artistId);
        final artistSongs = game.catalogSongsFor(artistId);

        return Scaffold(
          appBar: AppBar(title: Text(artist.name)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ArtistCharacterAvatar(
                    appearance: artist.appearance,
                    size: 140,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Popularity: ${artist.attributes['popularity']?.toStringAsFixed(0)}%', style: TextStyle(fontSize: 18)),
                Text('Label: ${game.labelDisplayName(artist)}', style: TextStyle(fontSize: 18)),
                Text('Total Streams: ${cumulativeStreams.toStringAsFixed(0)}', style: TextStyle(fontSize: 18)),
                if (game.isOnRoster(artistId))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'On your roster · they keep ${((game.rosterFor(artistId)?.artistKeep ?? 0) * 100).round()}% · ${game.activeRoster.length}/${RecordLabels.maxRosterSize}',
                      style: TextStyle(color: Color(0xFFFFD700)),
                    ),
                  ),
                if (game.isRival(artistId))
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('This artist is your chart rival.',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  ),
                const SizedBox(height: 16),
                if (artistId != game.player?.id)
                  ElevatedButton.icon(
                    onPressed: () {
                      final err = game.requestCollab(artistId);
                      if (err != null) {
                        ToastService().showError(err);
                      } else {
                        ToastService().showSuccess('Collab recorded!');
                      }
                    },
                    icon: Icon(Icons.handshake),
                    label: Text('Request Collab (\$400)'),
                  ),
                if (artistId != game.player?.id && !game.isOnRoster(artistId)) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: game.activeRoster.length >= RecordLabels.maxRosterSize
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignContractScreen(
                                  artistId: artistId,
                                ),
                              ),
                            );
                          },
                    icon: Icon(Icons.assignment),
                    label: Text(
                      game.activeRoster.length >= RecordLabels.maxRosterSize
                          ? 'Roster full (${RecordLabels.maxRosterSize})'
                          : 'Open signing contract',
                    ),
                  ),
                ],
                if (game.isOnRoster(artistId)) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RosterArtistStyleScreen(
                            artistId: artistId,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.checkroom),
                    label: Text('Edit name & outfit'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final err = game.commissionRosterDemo(artistId);
                      if (err != null) {
                        ToastService().showError(err);
                      } else {
                        ToastService().showSuccess('Demo cut — release it on Music');
                      }
                    },
                    icon: Icon(Icons.mic),
                    label: Text('Send to studio (\$400 demo)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _pickTeamCollab(context, game, artistId),
                    icon: Icon(Icons.group_add),
                    label: Text('Collab (player / team / outside)'),
                  ),
                ],
                if (game.isRival(artistId) && artistId != game.player?.id) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final err = game.dropDissTrack(artistId);
                      if (err != null) {
                        ToastService().showError(err);
                      } else {
                        ToastService().showSuccess('Diss dropped.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    icon: Icon(Icons.whatshot),
                    label: Text(
                      game.dissCooldownWeeks > 0
                          ? 'Diss cooling (${game.dissCooldownWeeks}w)'
                          : 'Drop Diss Track (\$150)',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text('Attributes:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: artist.attributes.entries.map((e) => Chip(label: Text('${e.key}: ${e.value.toStringAsFixed(0)}%'))).toList(),
                ),
                const SizedBox(height: 16),
                Text('Songs:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (artistSongs.isEmpty)
                  Text('No songs released yet.')
                else
                  ...artistSongs.map((song) => ListTile(
                    title: Text(
                      song.released ? song.title : '${song.title} (demo)',
                    ),
                    subtitle: Text(
                      '${game.songCredit(song)} · Streams: ${song.totalStreams.toStringAsFixed(0)} | Weekly: ${song.weeklyListeners.toStringAsFixed(0)}',
                    ),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickTeamCollab(
    BuildContext context,
    GameStateService game,
    String artistId,
  ) {
    final player = game.player;
    final options = <_CollabPick>[
      if (player != null)
        _CollabPick(player.id, '${player.name} (you)'),
      ...game.activeRoster
          .where((s) => s.artistId != artistId)
          .map((s) {
            final a = game.getArtistById(s.artistId);
            return _CollabPick(s.artistId, a?.name ?? s.artistId);
          }),
    ];
    final outsiders = game.worldArtists
        .where((a) =>
            a.id != artistId &&
            a.id != player?.id &&
            !game.isOnRoster(a.id))
        .toList()
      ..sort((a, b) => (b.attributes['popularity'] ?? 0)
          .compareTo(a.attributes['popularity'] ?? 0));
    for (final a in outsiders.take(8)) {
      options.add(_CollabPick(a.id, '${a.name} (outside)'));
    }
    showModalBottomSheet<void>(
      context: context,
            builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Who should they collab with?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...options.map(
                (pick) => ListTile(
                  title: Text(pick.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(ctx);
                    final err = game.commissionRosterDemo(
                      artistId,
                      collabArtistId: pick.id,
                    );
                    if (err != null) {
                      ToastService().showError(err);
                    } else {
                      ToastService().showSuccess('Collab demo cut');
                    }
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

class _CollabPick {
  final String id;
  final String name;
  const _CollabPick(this.id, this.name);
}
