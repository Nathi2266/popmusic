import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/record_labels.dart';
import '../services/game_state_service.dart';
import 'label_detail_screen.dart';

class LabelsScreen extends StatelessWidget {
  const LabelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, game, _) {
        final labels = game.visibleLabels();
        return Scaffold(
          appBar: AppBar(
            title: Text('Record Labels'),
                      ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: labels.length,
            itemBuilder: (context, index) {
              final label = labels[index];
              final roster = game.artistsOnLabel(label.id);
              final isYours = label.id == RecordLabels.playerImprintId;
              final signedHere = game.playerLabelId == label.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LabelDetailScreen(labelId: label.id),
                        ),
                      );
                    },
                    child: Semantics(
                      button: true,
                      label: '${label.name}, ${label.displayTier}, ${roster.length} artists',
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Color(label.colorValue),
                              child: Text(
                                label.name.isEmpty ? '?' : label.name[0],
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          label.name,
                                          style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isYours)
                                        _Badge(
                                          text: 'YOURS',
                                          color: Theme.of(context).colorScheme.primary,
                                        )
                                      else if (signedHere)
                                        const _Badge(
                                          text: 'SIGNED',
                                          color: Color(0xFFFFD700),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${label.displayTier} · ${label.city} · ${roster.length} artist${roster.length == 1 ? '' : 's'}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    label.blurb,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
