import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';

class ChartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateService>(context);
    final topSongs = gameState.worldSongs.take(30).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Top 30 Songs'),
      ),
      body: ListView.builder(
        itemCount: topSongs.length,
        itemBuilder: (context, index) {
          final song = topSongs[index];
          return ListTile(
            leading: Text('#${index + 1}'),
            title: Text(song.title),
            subtitle: Text('Artist: ${song.artistName}'),
            trailing: Text('Streams: ${song.streams}'),
          );
        },
      ),
    );
  }
}
