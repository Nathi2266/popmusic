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
            title: const Text('Record Labels'),
            backgroundColor: const Color(0xFF16213e),
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
                  color: const Color(0xFF2a2a3e),
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
                                style: const TextStyle(
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isYours)
                                        const _Badge(
                                          text: 'YOURS',
                                          color: Color(0xFFe94560),
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
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    label.blurb,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white38),
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
