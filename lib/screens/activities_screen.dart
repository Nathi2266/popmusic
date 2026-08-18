import 'package:flutter/material.dart';

import '../theme/game_palette.dart';
import '../widgets/game_shell.dart';
import 'artists_screen.dart';
import 'career_screen.dart';
import 'challenges_screen.dart';
import 'performance_screen.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        leading: const GameDrawerButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Get out of the studio',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _ActivityTile(
            icon: Icons.mic,
            title: 'Perform',
            subtitle: 'Shows, tours, and stage time',
            color: p.primary,
            onTap: () => _open(context, const PerformanceScreen()),
          ),
          _ActivityTile(
            icon: Icons.people,
            title: 'Artists',
            subtitle: 'Browse the scene and sign talent',
            color: p.gold,
            onTap: () => _open(context, const ArtistsScreen()),
          ),
          _ActivityTile(
            icon: Icons.star,
            title: 'Career',
            subtitle: 'Awards, reputation, and milestones',
            color: p.primary,
            onTap: () => _open(context, const CareerScreen()),
          ),
          _ActivityTile(
            icon: Icons.flag,
            title: 'Challenges',
            subtitle: 'Daily and weekly goals',
            color: p.gold,
            onTap: () => _open(context, const ChallengesScreen()),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.18),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
