import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../models/summary_models.dart';
import '../models/event.dart';

// -----------------------------
// UI: ProceedWeekButton + EventPopup
// -----------------------------

class ProceedWeekButton extends StatelessWidget {
const ProceedWeekButton({super.key});

@override
Widget build(BuildContext context) {
 return ElevatedButton.icon(
   icon: const Icon(Icons.skip_next),
   label: const Text('Proceed Week'),
   onPressed: () async {
     final game = Provider.of<GameStateService>(context, listen: false);
     game.advanceWeek();
     await showDialog(
       context: context,
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
 final activities = game.lastWeekActivities;
 final topCharts = game.worldSongs.take(5).toList();

 return Dialog(
   insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
   child: ConstrainedBox(
     constraints: const BoxConstraints(maxHeight: 600),
     child: Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         Padding(
           padding: const EdgeInsets.all(12),
           child: Row(
             children: [
               const Icon(Icons.event_note),
               const SizedBox(width: 10),
               Expanded(child: Text('Week ${game.weekOfMonth} • Month ${game.currentMonth} • ${game.currentYear}', style: const TextStyle(fontWeight: FontWeight.bold))),
               TextButton(
                 onPressed: () => Navigator.of(context).pop(),
                 child: const Text('Close'),
               )
             ],
           ),
         ),
         Expanded(
           child: SingleChildScrollView(
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   if (events.isNotEmpty) ...[
                     const Text('Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                     ...events.map((e) => _buildEventCard(e)),
                   ],
                   if (activities.isNotEmpty) ...[
                     const Text('Artist Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                     ...activities.map((a) => _buildActivityRow(a)),
                   ],
                   const Text('Top Charts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                   ...topCharts.map((s) => _buildChartRow(s)),
                   const Text('Player Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                   Text('${game.player!.name} • Money: \$${game.player!.money.toStringAsFixed(0)}'),
                   Wrap(
                     spacing: 8,
                     runSpacing: 6,
                     children: game.player!.attributes.toMap().entries.map((e) => Chip(label: Text('${e.key}: ${e.value.toStringAsFixed(0)}%'))).toList(),
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

Widget _buildEventCard(GameEvent e) {
 Color bg = Colors.grey.shade800; // Default background color for better contrast
 switch (e.severity) {
   case EventSeverity.low:
     bg = Colors.blueGrey.shade800;
     break;
   case EventSeverity.medium:
     bg = Colors.orange.shade800;
     break;
   case EventSeverity.high:
   // No default needed as all enum values are covered
 }
 return Card(
   color: bg,
   child: Padding(
     padding: const EdgeInsets.all(10),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
         Text(e.description, style: const TextStyle(color: Colors.white70)),
       ],
     ),
   ),
 );
}

Widget _buildActivityRow(ArtistActivity a) {
 return ListTile(
   dense: true,
   leading: const Icon(Icons.person),
   title: Text(a.artistName),
   subtitle: Text(a.activity),
 );
}

Widget _buildChartRow(SongSummary s) {
 return ListTile(
   dense: true,
   leading: const Icon(Icons.music_note),
   title: Text(s.title),
   subtitle: Text('${s.artistName} • ${s.streams.toStringAsFixed(0)} streams'),
 );
}
}
