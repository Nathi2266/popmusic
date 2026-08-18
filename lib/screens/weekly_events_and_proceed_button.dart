import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../models/event.dart';
import '../models/song.dart';

class ProceedWeekButton extends StatelessWidget {
  const ProceedWeekButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.skip_next),
      label: Text('Proceed Week'),
      onPressed: () async {
        final game = Provider.of<GameStateService>(context, listen: false);
        game.proceedWeek();
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ChangeNotifierProvider.value(
            value: game,
            child: const EventPopup(),
          ),
        );
      },
    );
  }
}

class EventPopup extends StatelessWidget {
  const EventPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateService>(context);
    final events = game.lastWeekEvents;
    final topCharts = game.getTopSongs(5);
    final pending = game.pendingPlayerDecisions;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.event_note),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Week ${game.weekOfMonth} • Month ${game.month} • ${game.year}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: pending.isEmpty
                        ? () => Navigator.of(context).pop()
                        : null,
                    child: Text(pending.isEmpty ? 'Close' : 'Decide first'),
                  ),
                ],
              ),
            ),
            if (pending.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${pending.length} decision${pending.length == 1 ? '' : 's'} need your call',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (events.isNotEmpty) ...[
                        Text(
                          'Events',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        ...events.map(
                          (e) => _EventCard(
                            event: e,
                            onChoice: (choice) =>
                                game.resolveEventChoice(e.id, choice),
                          ),
                        ),
                      ],
                      Text(
                        'Top Charts',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      ...topCharts.map((s) => _buildChartRow(s, game)),
                      Text(
                        'Player Summary',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${game.player!.name} • Money: \$${game.playerMoney.toStringAsFixed(0)} • Fans: ${game.playerFanCount}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartRow(Song s, GameStateService game) {
    final artist = game.getArtistById(s.artistId);
    return ListTile(
      dense: true,
      leading: Icon(Icons.music_note),
      title: Text(s.title),
      subtitle: Text(
        '${artist?.name ?? 'Unknown Artist'} • ${s.weeklyListeners.toStringAsFixed(0)} listeners',
      ),
      trailing: Text('${s.totalStreams.toStringAsFixed(0)} streams'),
    );
  }
}

class _EventCard extends StatelessWidget {
  final GameEvent event;
  final void Function(String choice) onChoice;

  const _EventCard({required this.event, required this.onChoice});

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.grey.shade800;
    switch (event.severity) {
      case EventSeverity.low:
        bg = Colors.blueGrey.shade800;
        break;
      case EventSeverity.medium:
        bg = Colors.orange.shade800;
        break;
      case EventSeverity.high:
        bg = Colors.red.shade800;
        break;
    }

    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              event.description,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72)),
            ),
            if (event.needsPlayerDecision) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: event.choices
                    .map(
                      (choice) => ElevatedButton(
                        onPressed: () => onChoice(choice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: Text(choice),
                      ),
                    )
                    .toList(),
              ),
            ] else if (event.isInteractive && event.resolved) ...[
              const SizedBox(height: 8),
              Text(
                'You chose: ${event.selectedChoice}',
                style: TextStyle(
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
