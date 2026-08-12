import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/game_state_service.dart';
import '../models/song.dart';
// Removed Artist import as it's no longer used directly
// import '../models/artist.dart';
// Removed Genre import as it's no longer used
// import '../models/genre.dart';
import 'songwriting_minigame_screen.dart';
import 'production_minigame_screen.dart';
import '../data/titles.dart';
import '../utils/toast_service.dart';
import '../services/achievement_service.dart';
import '../models/studio_finish.dart';

class CreateSongScreen extends StatefulWidget {
  const CreateSongScreen({super.key});

  @override
  State<CreateSongScreen> createState() => _CreateSongScreenState();
}

class _CreateSongScreenState extends State<CreateSongScreen> {
  final _titleController = TextEditingController();
  String _selectedGenre = 'Pop';
  int _songwritingScore = 0;
  int _productionScore = 0;
  bool _hasPlayedSongwriting = false;
  bool _hasPlayedProduction = false;
  String _estimatedRank = 'Calculating...';
  bool _marketingBoostEnabled = false;
  double _songLengthMinutes = 3.5; // Default song length
  StudioFinish _studioFinish = StudioFinish.standard;
  bool _hireGhostwriter = false;
  bool _useSample = false;
  bool _clearSampleNow = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final game = Provider.of<GameStateService>(context, listen: false);
      setState(() {
        _selectedGenre = game.playerHomeGenre;
      });
      _calculateEstimatedRank();
    });
  }

  void _calculateEstimatedRank() {
    final gameState = Provider.of<GameStateService>(context, listen: false);
    final player = gameState.player;

    if (player == null) {
      setState(() {
        _estimatedRank = 'N/A';
      });
      return;
    }

    final songwritingComponent = _hasPlayedSongwriting
        ? _songwritingScore
        : (player.attributes['songwriting'] ?? 0).toInt();
    final productionComponent = _hasPlayedProduction
        ? _productionScore
        : (player.attributes['production'] ?? 0).toInt();

    // Base score from songwriting and production
    final baseScore = (songwritingComponent + productionComponent) / 2;

    // Influence of player attributes
    final charismaFactor = (player.attributes['charisma'] ?? 0) * 0.2;
    final marketingFactor = (player.attributes['marketing'] ?? 0) * 0.3;
    final networkingFactor = (player.attributes['networking'] ?? 0) * 0.1;

    double totalScore = baseScore + charismaFactor + marketingFactor + networkingFactor;

    if (_marketingBoostEnabled) {
      totalScore = totalScore * 1.1; // 10% boost for marketing
    }
    totalScore *= _studioFinish.qualityMult;
    if (_hireGhostwriter) {
      totalScore = (totalScore + 12).clamp(0, 100);
    }

    // Map total score to an estimated rank
    String rank;
    if (totalScore >= 95) {
      rank = 'Top 5';
    } else if (totalScore >= 90) {
      rank = 'Top 10';
    } else if (totalScore >= 80) {
      rank = 'Top 20';
    } else if (totalScore >= 70) {
      rank = 'Top 50';
    } else if (totalScore >= 60) {
      rank = 'Top 100';
    } else {
      rank = 'Outside Top 100';
    }

    setState(() {
      _estimatedRank = rank;
    });
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
      _calculateEstimatedRank();
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
      _calculateEstimatedRank();
    }
  }

  void _releaseSong() {
    if (_titleController.text.trim().isEmpty) {
      ToastService().showError('Please enter a song title');
      return;
    }

    final gameState = Provider.of<GameStateService>(context, listen: false);
    final player = gameState.player;

    if (player == null) {
      ToastService().showError('Player data not available');
      return;
    }

    final songwritingComponent = _hasPlayedSongwriting
        ? _songwritingScore
        : (player.attributes['songwriting'] ?? 0).toInt();
    final productionComponent = _hasPlayedProduction
        ? _productionScore
        : (player.attributes['production'] ?? 0).toInt();

    var writing = songwritingComponent.toDouble();
    if (_hireGhostwriter) {
      writing = writing < 78 ? 78 : (writing + 8).clamp(0, 100);
    }
    var popularityFactor =
        ((writing + productionComponent) / 2).clamp(0, 100).toDouble();
    // Low stamina hurts craft quality (matches release warning copy)
    final stamina = (player.attributes['stamina'] ?? 0).toDouble();
    if (stamina < 30) {
      popularityFactor = (popularityFactor * 0.75).clamp(0, 100).toDouble();
    }
    popularityFactor =
        (popularityFactor * _studioFinish.qualityMult).clamp(0, 100).toDouble();
    double currentViralFactor = ((player.attributes['marketing'] ?? 0) * 0.5 +
            (player.attributes['charisma'] ?? 0) * 0.3 +
            Random().nextInt(20))
        .clamp(0, 100)
        .toDouble();
    if (_marketingBoostEnabled) {
      currentViralFactor = (currentViralFactor * 1.2).clamp(0, 100);
    }
    currentViralFactor =
        (currentViralFactor * _studioFinish.viralMult).clamp(0, 100);
    if (_useSample) {
      currentViralFactor = (currentViralFactor + 14).clamp(0, 100);
    }
    final salesPotential = ((player.attributes['networking'] ?? 0) * 0.4 +
            (player.attributes['wealth'] ?? 0) * 0.3 +
            Random().nextInt(30))
        .clamp(0, 100)
        .toDouble();
    final releaseCost = gameState.songReleaseCost(
      marketingBoost: _marketingBoostEnabled,
      finish: _studioFinish,
      ghostwriter: _hireGhostwriter,
      sampleClearance: _useSample && _clearSampleNow,
    );

    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF16213e),
        title: const Text('Confirm Song Release', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Title: ${_titleController.text.trim()}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              // Placeholder for Cover Art - will implement later
              Container(
                width: 100,
                height: 100,
                color: Colors.grey,
                child: const Center(child: Text('Cover Art', style: TextStyle(color: Colors.white70))),
              ),
              const SizedBox(height: 8),
              Text('Estimated Rank: $_estimatedRank', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Viral Factor: ${currentViralFactor.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Popularity Factor: ${popularityFactor.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Sales Potential: ${salesPotential.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Song Length: ${_songLengthMinutes.toStringAsFixed(1)} minutes', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Genre: $_selectedGenre', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Studio: ${_studioFinish.displayName}', style: const TextStyle(color: Colors.white70)),
              if (_hireGhostwriter) ...[
                const SizedBox(height: 8),
                Text(
                  'Ghostwriter \$${gameState.ghostwriterFee().toStringAsFixed(0)} · leak risk',
                  style: const TextStyle(color: Color(0xFFFFB74D)),
                ),
              ],
              if (_useSample) ...[
                const SizedBox(height: 8),
                Text(
                  _clearSampleNow
                      ? 'Sample cleared \$${gameState.sampleClearanceFee().toStringAsFixed(0)}'
                      : 'Uncleared sample — takedown risk',
                  style: TextStyle(
                    color: _clearSampleNow
                        ? const Color(0xFF81D4FA)
                        : const Color(0xFFFFB74D),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text('Release Cost: \$${releaseCost.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFe94560))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              final song = Song(
                id: 'song_${DateTime.now().millisecondsSinceEpoch}',
                title: _titleController.text.trim(),
                artistId: player.id,
                totalStreams: 0,
                weeklyListeners: 0,
                weeksSinceRelease: 0,
                popularityFactor: popularityFactor,
                viralFactor: currentViralFactor,
                salesPotential: salesPotential,
                lengthMinutes: _songLengthMinutes,
                genre: _selectedGenre,
                studioFinish: _studioFinish.name,
                ghostwritten: _hireGhostwriter,
                usesSample: _useSample,
                sampleCleared: _useSample && _clearSampleNow,
              );

              gameState.addSong(song);
              final leaked = _hireGhostwriter &&
                  gameState.resolveGhostwriterLeak(song);
              final achievementService = Provider.of<AchievementService>(context, listen: false);
              gameState.checkSongAchievements(achievementService);
              gameState.updatePlayerMoney(-releaseCost);
              gameState.updatePlayerAttribute('stamina', -_studioFinish.staminaHit);

              Navigator.pop(context);

              ToastService().showSuccess('Released "${song.title}"!');
              if (context.mounted) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (partyCtx) => AlertDialog(
                    backgroundColor: const Color(0xFF16213e),
                    title: const Text('Listening Party',
                        style: TextStyle(color: Colors.white)),
                    content: Text(
                      'Host a room for "${song.title}" this week?',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      for (final pick in [
                        'Invite Press',
                        'Invite Fans',
                        'Quiet Drop',
                      ])
                        TextButton(
                          onPressed: () {
                            Navigator.pop(partyCtx);
                            final err = gameState.runListeningParty(
                              song.id,
                              pick,
                            );
                            if (err != null) {
                              ToastService().showError(err);
                              gameState.runListeningParty(
                                song.id,
                                'Quiet Drop',
                              );
                            } else {
                              ToastService().showSuccess(pick);
                            }
                            gameState.recalculateCharts();
                            if (leaked && context.mounted) {
                              showDialog<void>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF16213e),
                                  title: const Text('Ghostwriter Leak',
                                      style: TextStyle(color: Colors.white)),
                                  content: Text(
                                    'A writer for "${song.title}" talked. How do you spin it?',
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                  actions: [
                                    for (final spin in [
                                      'Own It',
                                      'Deny Everything',
                                      'Pay for Silence',
                                    ])
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          gameState.resolveGhostwriterSpin(
                                              spin);
                                          ToastService().showSuccess(spin);
                                        },
                                        child: Text(spin),
                                      ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Text(pick),
                        ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Confirm Release'),
          ),
        ],
      );
    });
  }

  void _generateRandomTitle() {
    final randomTitle = autoGeneratedSongTitles[Random().nextInt(autoGeneratedSongTitles.length)];
    _titleController.text = randomTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        // Removed player variable as it's no longer used directly
        // final player = gameState.player;

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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Enter song title (e.g., "Summer Jam")',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF2a2a3e),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _generateRandomTitle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFe94560),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Icon(Icons.casino, size: 28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Genre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<GameStateService>(
                  builder: (context, game, _) {
                    final trending = game.trendingGenre;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trending now: $trending (heat ${game.genreHeatFor(trending).toStringAsFixed(0)})',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: game.availableGenres.map((genre) {
                            final selected = _selectedGenre == genre;
                            final heat = game.genreHeatFor(genre);
                            return ChoiceChip(
                              label: Text(
                                '$genre · ${heat.toStringAsFixed(0)}',
                              ),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedGenre = genre;
                                  _calculateEstimatedRank();
                                });
                              },
                              backgroundColor: const Color(0xFF2a2a3e),
                              selectedColor: genre == trending
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFe94560),
                              labelStyle: TextStyle(
                                color: selected && genre == trending
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

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
                const SizedBox(height: 16),

                // Estimated Chart Rank
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
                        'Estimated Debut Rank',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _estimatedRank,
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'STUDIO FINISH',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...StudioFinish.values.map((finish) {
                  final selected = _studioFinish == finish;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _studioFinish = finish;
                          _calculateEstimatedRank();
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a3e),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFe94560)
                                : Colors.white24,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              finish.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              finish.pitch,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a3e),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hire ghostwriter (\$${gameState.ghostwriterFee().toStringAsFixed(0)}) — better writing, leak risk',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Switch(
                        value: _hireGhostwriter,
                        onChanged: (value) {
                          setState(() {
                            _hireGhostwriter = value;
                            _calculateEstimatedRank();
                          });
                        },
                        // ignore: deprecated_member_use
                        activeColor: const Color(0xFFFFB74D),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a3e),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Use a sample hook — extra viral, clearance optional',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Switch(
                        value: _useSample,
                        onChanged: (value) {
                          setState(() {
                            _useSample = value;
                            if (!value) _clearSampleNow = false;
                            _calculateEstimatedRank();
                          });
                        },
                        // ignore: deprecated_member_use
                        activeColor: const Color(0xFF81D4FA),
                      ),
                    ],
                  ),
                ),
                if (_useSample) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a3e),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _clearSampleNow
                            ? const Color(0xFF81D4FA)
                            : const Color(0xFFFFB74D),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _clearSampleNow
                                ? 'Clear sample now (\$${gameState.sampleClearanceFee().toStringAsFixed(0)})'
                                : 'Uncleared — hotter hook, takedown risk',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Switch(
                          value: _clearSampleNow,
                          onChanged: (value) {
                            setState(() {
                              _clearSampleNow = value;
                            });
                          },
                          // ignore: deprecated_member_use
                          activeColor: const Color(0xFF81D4FA),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
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
                        'Spend extra \$500 on marketing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Switch(
                        value: _marketingBoostEnabled,
                        onChanged: (value) {
                          setState(() {
                            _marketingBoostEnabled = value;
                            _calculateEstimatedRank();
                          });
                        },
                        // ignore: deprecated_member_use
                        activeColor: const Color(0xFFe94560),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Song Length Slider
                const Text(
                  'Song Length',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _songLengthMinutes,
                  min: 2.0,
                  max: 6.0,
                  divisions: 8, // 2.0, 2.5, 3.0, ..., 6.0
                  label: '${_songLengthMinutes.toStringAsFixed(1)} min',
                  onChanged: (value) {
                    setState(() {
                      _songLengthMinutes = value;
                    });
                  },
                  activeColor: const Color(0xFFe94560),
                  inactiveColor: Colors.white38,
                ),
                const SizedBox(height: 24),

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
                        '\$${gameState.songReleaseCost(marketingBoost: _marketingBoostEnabled, finish: _studioFinish, ghostwriter: _hireGhostwriter, sampleClearance: _useSample && _clearSampleNow).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: gameState.playerMoney >=
                                  gameState.songReleaseCost(
                                    marketingBoost: _marketingBoostEnabled,
                                    finish: _studioFinish,
                                    ghostwriter: _hireGhostwriter,
                                    sampleClearance: _useSample && _clearSampleNow,
                                  )
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

                // Stamina Warning
                if ((gameState.player?.attributes['stamina'] ?? 0) < 10) ...[
                  const Text(
                    'Warning: Low stamina may reduce song performance!',
                    style: TextStyle(
                      color: Color(0xFFF44336),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                // Release Button
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: gameState.playerMoney >=
                            gameState.songReleaseCost(
                              marketingBoost: _marketingBoostEnabled,
                              finish: _studioFinish,
                              ghostwriter: _hireGhostwriter,
                              sampleClearance: _useSample && _clearSampleNow,
                            )
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

  // Removed _getGenreName as genre is no longer part of Song model
  // String _getGenreName(Genre genre) {
  //   switch (genre) {
  //     case Genre.pop:
  //       return 'Pop';
  //     case Genre.rock:
  //       return 'Rock';
  //     case Genre.hiphop:
  //       return 'Hip Hop';
  //     case Genre.rnb:
  //       return 'R&B';
  //     case Genre.electronic:
  //       return 'Electronic';
  //     case Genre.indie:
  //       return 'Indie';
  //     case Genre.country:
  //       return 'Country';
  //     case Genre.jazz:
  //       return 'Jazz';
  //     case Genre.latin:
  //       return 'Latin';
  //     case Genre.kpop:
  //       return 'K-Pop';
  //   }
  // }
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
