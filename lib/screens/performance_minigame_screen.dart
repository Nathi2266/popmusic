import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:math';
import '../models/venue.dart';

class PerformanceMinigameScreen extends StatefulWidget {
  final Venue venue;

  const PerformanceMinigameScreen({
    super.key,
    required this.venue,
  });

  @override
  State<PerformanceMinigameScreen> createState() =>
      _PerformanceMinigameScreenState();
}

class _PerformanceMinigameScreenState extends State<PerformanceMinigameScreen>
    with TickerProviderStateMixin {
  int _score = 0;
  int _combo = 0;
  int _timeLeft = 30;
  int _crowdEnergy = 50;
  Timer? _timer;
  Timer? _noteTimer;
  Timer? _energyTimer;
  Ticker? _noteMover;
  final List<_Note> _notes = [];
  final Random _random = Random();
  int _difficulty = 1;
  late AnimationController _comboController;
  final List<_Particle> _particles = [];
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
    _noteTimer?.cancel();
    _energyTimer?.cancel();
    _noteMover?.dispose();
    _comboController.dispose();
    super.dispose();
  }

  void _startGame() {
    final baseTime = _difficulty == 1
        ? 45
        : _difficulty == 2
            ? 30
            : 20;
    final noteInterval = _difficulty == 1
        ? 1000
        : _difficulty == 2
            ? 800
            : 600;

    setState(() {
      _timeLeft = baseTime;
      _score = 0;
      _combo = 0;
      _crowdEnergy = 50;
      _notes.clear();
      _particles.clear();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });

    _noteTimer = Timer.periodic(Duration(milliseconds: noteInterval), (timer) {
      if (_timeLeft > 0) {
        _addNote();
      } else {
        timer.cancel();
      }
    });

    _energyTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_timeLeft > 0 && mounted) {
        setState(() {
          _crowdEnergy = (_crowdEnergy - 2).clamp(0, 100);
        });
      } else {
        timer.cancel();
      }
    });

    _noteMover?.dispose();
    _noteMover = createTicker((_) {
      if (_timeLeft > 0 && mounted) {
        _updateNotes();
      }
    })..start();
  }

  void _addNote() {
    setState(() {
      _notes.add(_Note(
        lane: _random.nextInt(4),
        id: DateTime.now().millisecondsSinceEpoch,
        y: 0.0,
      ));
    });
  }

  void _updateNotes() {
    setState(() {
      _notes.removeWhere((note) {
        note.y += 0.02;
        if (note.y > 1.0) {
          _combo = 0;
          _crowdEnergy = (_crowdEnergy - 2).clamp(0, 100);
          return true;
        }
        return false;
      });
    });
  }

  void _hitNote(int lane) {
    final noteIndex = _notes.indexWhere(
      (note) => note.lane == lane && note.y > 0.7 && note.y < 0.9,
    );

    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      final accuracy = 1.0 - (note.y - 0.8).abs() * 5;
      final baseScore = (10 * accuracy * _difficulty).toInt();
      final comboBonus = _combo * 2;

      setState(() {
        _notes.removeAt(noteIndex);
        _combo++;
        _score += baseScore + comboBonus;
        _crowdEnergy = (_crowdEnergy + 5).clamp(0, 100);

        // Add particle effect
        _particles.add(_Particle(
          x: (MediaQuery.of(context).size.width / 4) * lane +
              (MediaQuery.of(context).size.width / 8),
          y: MediaQuery.of(context).size.height * 0.8,
          id: DateTime.now().millisecondsSinceEpoch,
        ));
      });

      if (_combo > 1) {
        _comboController.forward(from: 0);
      }
    } else {
      setState(() {
        _combo = 0;
        _crowdEnergy = (_crowdEnergy - 3).clamp(0, 100);
      });
    }
  }

  void _endGame() {
    _timer?.cancel();
    _noteTimer?.cancel();
    _energyTimer?.cancel();
    _noteMover?.stop();
    final venueBonus = (widget.venue.capacity / 5000).clamp(0, 8).toInt();
    final energyBonus = (_crowdEnergy / 2).toInt();
    final finalScore =
        ((_score / 10) + energyBonus + venueBonus).clamp(0, 100).toInt();
    if (mounted) Navigator.pop(context, finalScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performing at ${widget.venue.name}'),
                automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surface,
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (_timeLeft ==
                          (_difficulty == 1
                              ? 45
                              : _difficulty == 2
                                  ? 30
                                  : 20))
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
                      Row(
                        children: [
                          Icon(Icons.timer, color: Theme.of(context).colorScheme.onSurface),
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
                      Text(
                        'Score: $_score',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_combo > 1)
                        ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.2).animate(
                            CurvedAnimation(
                              parent: _comboController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Text(
                            'Combo: x$_combo',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Crowd Energy Meter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Crowd Energy',
                            style:
                                TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 12),
                          ),
                          Text(
                            '$_crowdEnergy%',
                            style: TextStyle(
                              color: _crowdEnergy > 70
                                  ? const Color(0xFF4CAF50)
                                  : _crowdEnergy > 40
                                      ? const Color(0xFFFF9800)
                                      : const Color(0xFFF44336),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _crowdEnergy / 100,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _crowdEnergy > 70
                              ? const Color(0xFF4CAF50)
                              : _crowdEnergy > 40
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFFF44336),
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Game Area
            Expanded(
              child: Stack(
                children: [
                  // Stage background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),

                  // Lanes
                  Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: index < 3 ? 1 : 0,
                              ),
                            ),
                          ),
                          child: Column(
                            children: List.generate(20, (_) {
                              return Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white
                                            .withValues(alpha: 0.05),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    }),
                  ),

                  // Hit zone indicator
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.8 - 30,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                const Color(0xFF4CAF50).withValues(alpha: 0.5),
                            width: 2,
                          ),
                          bottom: BorderSide(
                            color:
                                const Color(0xFF4CAF50).withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Notes
                  ..._notes.map((note) {
                    return Positioned(
                      left: (MediaQuery.of(context).size.width / 4) * note.lane,
                      top: MediaQuery.of(context).size.height * note.y,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 4,
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Color(0xFFc7354d),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary
                                  .withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 32,
                        ),
                      ),
                    );
                  }),

                  // Particles
                  ..._particles.map((particle) {
                    final age =
                        DateTime.now().millisecondsSinceEpoch - particle.id;
                    if (age > 500) return const SizedBox.shrink();
                    return Positioned(
                      left: particle.x - 10,
                      top: particle.y - (age / 10),
                      child: Opacity(
                        opacity: 1.0 - (age / 500),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Hit Buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => _hitNote(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note {
  final int lane;
  final int id;
  double y;

  _Note({required this.lane, required this.id, required this.y});
}

class _Particle {
  final double x;
  final double y;
  final int id;

  _Particle({required this.x, required this.y, required this.id});
}
