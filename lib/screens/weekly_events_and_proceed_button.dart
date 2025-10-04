import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../models/event.dart';
import '../models/song.dart'; // Added import for Song model

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
     game.proceedWeek();
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
 // Removed activities as it's no longer used
 // final activities = game.lastWeekActivities;
 final topCharts = game.getTopSongs(5); // Changed to use getTopSongs and return Song objects

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
               Expanded(child: Text('Week ${game.weekOfMonth} • Month ${game.month} • ${game.year}', style: const TextStyle(fontWeight: FontWeight.bold))),
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
                   // Removed Artist Activities section
                   // if (activities.isNotEmpty) ...[
                   //   const Text('Artist Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                   //   ...activities.map((a) => _buildActivityRow(a)),
                   // ],
                   const Text('Top Charts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                   ...topCharts.map((s) => _buildChartRow(s, game)), // Pass game to access artist info
                   const Text('Player Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                   Text('${game.player!.name} • Money: \$${game.playerMoney.toStringAsFixed(0)}'), // Updated money access
                   Wrap(
                     spacing: 8,
                     runSpacing: 6,
                     children: game.player!.attributes.entries.map((e) => Chip(label: Text('${e.key}: ${e.value.toStringAsFixed(0)}%'))).toList(), // Updated attribute access
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

// Removed _buildActivityRow
// Widget _buildActivityRow(ArtistActivity a) {
//   return ListTile(
//     dense: true,
//     leading: const Icon(Icons.person),
//     title: Text(a.artistName),
//     subtitle: Text(a.activity),
//   );
// }

Widget _buildChartRow(Song s, GameStateService game) { // Changed to Song and added GameStateService parameter
  final artist = game.getArtistById(s.artistId);
  return ListTile(
    dense: true,
    leading: const Icon(Icons.music_note),
    title: Text(s.title),
    subtitle: Text('${artist?.name ?? 'Unknown Artist'} • ${s.weeklyListeners.toStringAsFixed(0)} listeners'), // Updated to weeklyListeners
    trailing: Text('${s.totalStreams.toStringAsFixed(0)} streams'), // Updated to totalStreams
  );
}
}
