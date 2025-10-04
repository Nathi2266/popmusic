import 'package:flutter/material.dart';

class AwardDetailScreen extends StatelessWidget {
  final List<String> awards;

  const AwardDetailScreen({super.key, required this.awards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awards Won'),
      ),
      body: awards.isEmpty
          ? const Center(child: Text('No awards won yet.'))
          : ListView.builder(
              itemCount: awards.length,
              itemBuilder: (context, index) {
                final award = awards[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                    title: Text(award, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
    );
  }
}
