import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/game_state_service.dart';
import '../models/song.dart';
import '../models/artist.dart';
import 'songwriting_minigame_screen.dart';
import 'production_minigame_screen.dart';

class CreateSongScreen extends StatefulWidget {
  const CreateSongScreen({super.key});

  @override
  State<CreateSongScreen> createState() => _CreateSongScreenState();
}

class _CreateSongScreenState extends State<CreateSongScreen> {
  final _titleController = TextEditingController();
  Genre? _selectedGenre;
  int _songwritingScore = 0;
  int _productionScore = 0;
  bool _hasPlayedSongwriting = false;
  bool _hasPlayedProduction = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _playSongwritingMinigame() async {
    final score = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => const SongwritingMinigameScreen(),
      ),
    );

    if (score != null) {
      setState(() {
        _songwritingScore = score;
        _hasPlayedSongwriting = true;
      });
    }
  }

  void _playProductionMinigame() async {
    final score = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductionMinigameScreen(),
      ),
    );

    if (score != null) {
      setState(() {
        _productionScore = score;
        _hasPlayedProduction = true;
      });
    }
  }

  void _releaseSong() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a song title')),
      );
      return;
    }

    if (_selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a genre')),
      );
      return;
    }

    final gameState = Provider.of<GameStateService>(context, listen: false);
    final player = gameState.player;

    if (player == null) return;

    // Calculate song quality based on minigame scores and attributes
    final songwritingComponent = _hasPlayedSongwriting
        ? _songwritingScore
        : player.attributes.songwriting.toInt();
    final productionComponent = _hasPlayedProduction
        ? _productionScore
        : player.attributes.production.toInt();
    
    final quality = ((songwritingComponent + productionComponent) / 2).toInt();
    final hypeLevel = (player.attributes.marketing * 0.5 + 
                       player.attributes.charisma * 0.3 + 
                       Random().nextInt(20)).toInt();

    final song = Song(
      id: 'song_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      artistId: player.id,
      genre: _selectedGenre!,
      quality: quality.clamp(0, 100),
      hypeLevel: hypeLevel.clamp(0, 100),
      streams: 0,
    );

    gameState.addSong(song);
    gameState.updatePlayerMoney(-500); // Cost to release
    gameState.updatePlayerAttribute('stamina', -10);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Released "${song.title}"!'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final player = gameState.player;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Song'),
            backgroundColor: const Color(0xFF16213e),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Song Title
                const Text(
                  'Song Title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter song title',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF2a2a3e),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Genre Selection
                const Text(
                  'Genre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: Genre.values.map((genre) {
                    final isSelected = _selectedGenre == genre;
                    return ChoiceChip(
                      label: Text(_getGenreName(genre)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGenre = genre;
                        });
                      },
                      backgroundColor: const Color(0xFF2a2a3e),
                      selectedColor: const Color(0xFFe94560),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Songwriting Minigame
                _MinigameCard(
                  title: 'Songwriting',
                  description: 'Write lyrics and melody',
                  score: _songwritingScore,
                  hasPlayed: _hasPlayedSongwriting,
                  onPlay: _playSongwritingMinigame,
                  icon: Icons.edit,
                ),
                const SizedBox(height: 16),

                // Production Minigame
                _MinigameCard(
                  title: 'Production',
                  description: 'Mix and master your track',
                  score: _productionScore,
                  hasPlayed: _hasPlayedProduction,
                  onPlay: _playProductionMinigame,
                  icon: Icons.tune,
                ),
                const SizedBox(height: 32),

                // Cost Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a3e),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Release Cost',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$500',
                        style: TextStyle(
                          color: player != null && player.money >= 500
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Release Button
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: player != null && player.money >= 500
                        ? _releaseSong
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe94560),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF2a2a3e),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'RELEASE SONG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getGenreName(Genre genre) {
    switch (genre) {
      case Genre.pop:
        return 'Pop';
      case Genre.rock:
        return 'Rock';
      case Genre.hiphop:
        return 'Hip Hop';
      case Genre.rnb:
        return 'R&B';
      case Genre.electronic:
        return 'Electronic';
      case Genre.indie:
        return 'Indie';
      case Genre.country:
        return 'Country';
      case Genre.jazz:
        return 'Jazz';
      case Genre.latin:
        return 'Latin';
      case Genre.kpop:
        return 'K-Pop';
    }
  }
}

class _MinigameCard extends StatelessWidget {
  final String title;
  final String description;
  final int score;
  final bool hasPlayed;
  final VoidCallback onPlay;
  final IconData icon;

  const _MinigameCard({
    required this.title,
    required this.description,
    required this.score,
    required this.hasPlayed,
    required this.onPlay,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPlayed
              ? const Color(0xFF4CAF50)
              : Colors.white24,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFe94560),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (hasPlayed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPlay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe94560),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(hasPlayed ? 'Replay' : 'Play'),
          ),
        ],
      ),
    );
  }
}
