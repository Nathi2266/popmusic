import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../widgets/glass_card.dart';
import '../utils/animations.dart';

enum WordCategory { emotion, action, object, nature }

class SongwritingMinigameScreen extends StatefulWidget {
  const SongwritingMinigameScreen({super.key});

  @override
  State<SongwritingMinigameScreen> createState() =>
      _SongwritingMinigameScreenState();
}

class _SongwritingMinigameScreenState extends State<SongwritingMinigameScreen>
    with SingleTickerProviderStateMixin {
  final Map<WordCategory, List<String>> _wordCategories = {
    WordCategory.emotion: ['love', 'heart', 'soul', 'feel', 'pain', 'joy', 'fear', 'hope'],
    WordCategory.action: ['dance', 'run', 'fly', 'fall', 'rise', 'break', 'heal', 'dream'],
    WordCategory.object: ['crown', 'chain', 'ring', 'key', 'door', 'mirror', 'light', 'fire'],
    WordCategory.nature: ['night', 'star', 'moon', 'sky', 'rain', 'sun', 'wind', 'ocean'],
  };

  final List<String> _selectedWords = [];
  int _score = 0;
  int _combo = 0;
  int _timeLeft = 30;
  Timer? _timer;
  Timer? _categoryTimer;
  WordCategory? _currentCategory;
  int _difficulty = 1; // 1 = Easy, 2 = Medium, 3 = Hard
  late AnimationController _comboController;
  final List<_Particle> _particles = [];
  List<String> _mixedWords = [];
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _selectRandomCategory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_started) {
        _started = true;
        _startGame();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _categoryTimer?.cancel();
    _comboController.dispose();
    super.dispose();
  }

  void _refreshMixedWords() {
    final pool = <String>[];
    for (final words in _wordCategories.values) {
      pool.addAll(words);
    }
    pool.shuffle();
    _mixedWords = pool.take(12).toList();
  }

  void _selectRandomCategory() {
    setState(() {
      _currentCategory = _wordCategories.keys.elementAt(
        Random().nextInt(_wordCategories.length),
      );
    });
  }

  void _startGame() {
    setState(() {
      _timeLeft = _difficulty == 1 ? 45 : _difficulty == 2 ? 30 : 20;
      _score = 0;
      _combo = 0;
      _selectedWords.clear();
      _particles.clear();
    });

    _timer?.cancel();
    _categoryTimer?.cancel();
    _refreshMixedWords();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });

    _categoryTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_timeLeft > 0 && mounted) {
        _selectRandomCategory();
        setState(_refreshMixedWords);
      } else {
        timer.cancel();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    _categoryTimer?.cancel();
    final finalScore = (_score * (3.33 / _difficulty)).clamp(0, 100).toInt();
    if (mounted) Navigator.pop(context, finalScore);
  }

  WordCategory? _categoryFor(String word) {
    for (final entry in _wordCategories.entries) {
      if (entry.value.contains(word)) return entry.key;
    }
    return null;
  }

  void _selectWord(String word) {
    if (_selectedWords.length < 8) {
      setState(() {
        _selectedWords.add(word);
        final onTheme = _categoryFor(word) == _currentCategory;
        if (onTheme) {
          final baseScore = 8 * _difficulty;
          final comboBonus = _combo * 3;
          _score += baseScore + comboBonus;
          _combo++;
        } else {
          _score += 2 * _difficulty;
          _combo = 0;
        }
        
        // Add particle effect
        _particles.add(_Particle(
          x: Random().nextDouble() * 200,
          y: Random().nextDouble() * 200,
          id: DateTime.now().millisecondsSinceEpoch,
        ));
        
        // Remove particles after animation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _particles.removeWhere((p) => 
                DateTime.now().millisecondsSinceEpoch - p.id > 500);
            });
          }
        });
      });
      
      if (_combo > 1) {
        _comboController.forward(from: 0);
      }
    }
  }

  void _removeWord(int index) {
    setState(() {
      _selectedWords.removeAt(index);
      _score = max(0, _score - (5 * _difficulty));
      _combo = max(0, _combo - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Songwriting'),
                automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).colorScheme.surface],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Difficulty and Stats
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Difficulty',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 12),
                              ),
                              Text(
                                _difficulty == 1 ? 'Easy' : _difficulty == 2 ? 'Medium' : 'Hard',
                                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_timeLeft == (_difficulty == 1 ? 45 : _difficulty == 2 ? 30 : 20))
                            DropdownButton<int>(
                              value: _difficulty,
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('Easy')),
                                DropdownMenuItem(value: 2, child: Text('Medium')),
                                DropdownMenuItem(value: 3, child: Text('Hard')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _difficulty = value;
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: Theme.of(context).colorScheme.onSurface, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$_timeLeft s',
                            style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Score: $_score',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Combo Display
              if (_combo > 1)
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _comboController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    borderColor: const Color(0xFF4CAF50),
                    borderWidth: 2,
                    child: Text(
                      'COMBO x$_combo!',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_combo > 1) const SizedBox(height: 16),

              // Category Indicator
              if (_currentCategory != null)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: const Color(0xFF9C27B0),
                  borderWidth: 2,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(_currentCategory!),
                        color: const Color(0xFF9C27B0),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Category: ${_getCategoryName(_currentCategory!)}',
                        style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Selected Words
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Lyrics',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: _selectedWords.isEmpty
                          ? Center(
                              child: Text(
                                'Select words to build your lyrics',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedWords.asMap().entries.map((entry) {
                                return AppAnimations.scaleIn(
                                  child: Chip(
                                    label: Text(entry.value),
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    deleteIcon: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    onDeleted: () => _removeWord(entry.key),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Word Selection
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2,
                  ),
                  itemCount: _mixedWords.length,
                  itemBuilder: (context, index) {
                    final word = _mixedWords[index];
                    final isSelected = _selectedWords.contains(word);
                    final onTheme = _categoryFor(word) == _currentCategory;
                    return AppAnimations.fadeIn(
                      duration: Duration(milliseconds: 200 + (index * 50)),
                      child: ElevatedButton(
                        onPressed: isSelected ? null : () => _selectWord(word),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.12)
                              : onTheme
                                  ? const Color(0xFF4A148C)
                                  : Theme.of(context).colorScheme.surface,
                          foregroundColor: onTheme
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          disabledBackgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Finish Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _endGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'FINISH',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(WordCategory category) {
    switch (category) {
      case WordCategory.emotion:
        return Icons.favorite;
      case WordCategory.action:
        return Icons.directions_run;
      case WordCategory.object:
        return Icons.star;
      case WordCategory.nature:
        return Icons.landscape;
    }
  }

  String _getCategoryName(WordCategory category) {
    switch (category) {
      case WordCategory.emotion:
        return 'Emotions';
      case WordCategory.action:
        return 'Actions';
      case WordCategory.object:
        return 'Objects';
      case WordCategory.nature:
        return 'Nature';
    }
  }
}

class _Particle {
  final double x;
  final double y;
  final int id;

  _Particle({required this.x, required this.y, required this.id});
}
