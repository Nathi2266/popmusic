import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/game_state_service.dart';
import '../models/label_tier.dart';
import '../models/record_label.dart';
import '../data/record_labels.dart';
import '../utils/toast_service.dart';

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
        final artistSongs = game.catalogSongsFor(artistId);

        return Scaffold(
          appBar: AppBar(title: Text(artist.name)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Popularity: ${artist.attributes['popularity']?.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 18)),
                Text('Label: ${game.labelDisplayName(artist)}', style: const TextStyle(fontSize: 18)),
                Text('Total Streams: ${cumulativeStreams.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
                if (game.isOnRoster(artistId))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'On your roster · ${game.rosterFor(artistId)?.deal.displayName ?? 'Signed'} · ${game.activeRoster.length}/${RecordLabels.maxRosterSize}',
                      style: const TextStyle(color: Color(0xFFFFD700)),
                    ),
                  ),
                if (game.isRival(artistId))
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('This artist is your chart rival.',
                        style: TextStyle(color: Color(0xFFe94560))),
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
                    icon: const Icon(Icons.handshake),
                    label: const Text('Request Collab (\$400)'),
                  ),
                if (artistId != game.player?.id && !game.isOnRoster(artistId)) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _offerContract(context, game, artistId),
                    icon: const Icon(Icons.assignment),
                    label: Text(
                      game.activeRoster.length >= RecordLabels.maxRosterSize
                          ? 'Roster full (${RecordLabels.maxRosterSize})'
                          : 'Offer contract (sign to your label)',
                    ),
                  ),
                ],
                if (game.isOnRoster(artistId)) ...[
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
                    icon: const Icon(Icons.mic),
                    label: const Text('Send to studio (\$400 demo)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _pickTeamCollab(context, game, artistId),
                    icon: const Icon(Icons.group_add),
                    label: const Text('Collab (player / team / outside)'),
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
                      backgroundColor: const Color(0xFFe94560),
                    ),
                    icon: const Icon(Icons.whatshot),
                    label: Text(
                      game.dissCooldownWeeks > 0
                          ? 'Diss cooling (${game.dissCooldownWeeks}w)'
                          : 'Drop Diss Track (\$150)',
                    ),
                  ),
                ],
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

  void _offerContract(
    BuildContext context,
    GameStateService game,
    String artistId,
  ) {
    final artist = game.getArtistById(artistId);
    if (artist == null) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a3e),
        title: Text(
          'Contract for ${artist.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'They have to sign the paper. Max 5 artists on your imprint.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ...LabelDealStyle.values.map((deal) {
                final cost = RosterSigning.signingCost(
                  artist.attributes['popularity'] ?? 10,
                  deal,
                );
                final signing = RosterSigning(
                  artistId: artistId,
                  deal: deal,
                  signedYear: game.year,
                  signedMonth: game.month,
                  signedWeek: game.weekOfMonth,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      final err = game.signArtist(artistId, deal);
                      if (err != null) {
                        ToastService().showError(err);
                      } else {
                        ToastService().showSuccess(
                          '${artist.name} signed · ${deal.displayName}',
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '${deal.displayName} · \$${cost.toStringAsFixed(0)}\n'
                          'You keep ${(signing.playerCut * 100).toStringAsFixed(0)}% of their streams. ${deal.pitch}',
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
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
      backgroundColor: const Color(0xFF16213e),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Who should they collab with?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...options.map(
                (pick) => ListTile(
                  title: Text(pick.name, style: const TextStyle(color: Colors.white)),
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
