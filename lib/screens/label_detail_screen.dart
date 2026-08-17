import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/record_labels.dart';
import '../models/label_tier.dart';
import '../models/record_label.dart';
import '../models/song.dart';
import '../services/game_state_service.dart';
import '../utils/toast_service.dart';
import 'artist_detail_screen.dart';

class LabelDetailScreen extends StatelessWidget {
  final String labelId;

  const LabelDetailScreen({super.key, required this.labelId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, game, _) {
        final label = game.labelById(labelId);
        if (label == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Label')),
            body: const Center(child: Text('Label not found')),
          );
        }
        final roster = game.artistsOnLabel(label.id)
          ..sort((a, b) => (b.attributes['popularity'] ?? 0)
              .compareTo(a.attributes['popularity'] ?? 0));
        final isImprint = label.id == RecordLabels.playerImprintId;
        final cool = game.labelPitchCooldowns[label.id] ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(label.name),
            backgroundColor: const Color(0xFF16213e),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(label.colorValue),
                      Color(label.colorValue).withAlpha(140),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${label.displayTier} · ${label.city}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label.blurb,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (isImprint) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Roster ${game.activeRoster.length}/${RecordLabels.maxRosterSize}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isImprint) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: cool > 0
                        ? null
                        : () => _pitchSong(context, game, label),
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      cool > 0
                          ? 'A&R cooling ($cool w)'
                          : 'Submit a track (\$${label.pitchCost})',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe94560),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                isImprint ? 'YOUR ARTISTS' : 'ROSTER',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              if (roster.isEmpty)
                Text(
                  isImprint
                      ? 'Sign artists from the Artists tab. Max ${RecordLabels.maxRosterSize}.'
                      : 'Quiet roster this season.',
                  style: const TextStyle(color: Colors.white54),
                )
              else
                ...roster.map((artist) {
                  final signing = game.rosterFor(artist.id);
                  return Card(
                    color: const Color(0xFF2a2a3e),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(label.colorValue),
                        child: Text(
                          artist.name[0],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      title: Text(
                        artist.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        [
                          'Pop ${(artist.attributes['popularity'] ?? 0).toStringAsFixed(0)}%',
                          if (signing != null) signing.deal.displayName,
                        ].join(' · '),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArtistDetailScreen(artistId: artist.id),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _pitchSong(
    BuildContext context,
    GameStateService game,
    RecordLabel label,
  ) {
    final songs = game.playerSongs.where((s) => s.released).toList();
    if (songs.isEmpty) {
      ToastService().showError('Release a song first');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pitch to ${label.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If they bite and they outrank your current deal, you pick a contract.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return ListTile(
                        title: Text(song.title,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Streams ${song.totalStreams.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _offerDealThenPitch(context, game, label, song);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _offerDealThenPitch(
    BuildContext context,
    GameStateService game,
    RecordLabel label,
    Song song,
  ) {
    final wouldSignUp = game.player != null &&
        game.playerLabelId != label.id &&
        game.player!.labelTier.index < label.tier.index;
    if (!wouldSignUp) {
      final err = game.pitchTrackToLabel(song.id, label.id);
      if (err != null) {
        ToastService().showError(err);
      } else {
        ToastService().showSuccess('${label.name} took "${song.title}"');
      }
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a3e),
        title: Text(
          'Contract with ${label.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LabelDealStyle.values.map((deal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final err = game.pitchTrackToLabel(
                      song.id,
                      label.id,
                      deal: deal,
                    );
                    if (err != null) {
                      ToastService().showError(err);
                    } else {
                      ToastService().showSuccess(
                        '${label.name} · ${deal.displayName}',
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
                        '${deal.displayName}\n${deal.pitch}',
                        style: const TextStyle(height: 1.3),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
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
}
