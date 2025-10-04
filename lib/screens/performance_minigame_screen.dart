import 'package:flutter/material.dart';
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

class _PerformanceMinigameScreenState extends State<PerformanceMinigameScreen> {
  int _score = 0;
  int _combo = 0;
  int _timeLeft = 30;
  Timer? _timer;
  Timer? _noteTimer;
  final List<_Note> _notes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });

    _noteTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      _addNote();
    });
  }

  void _addNote() {
    setState(() {
      _notes.add(_Note(
        lane: _random.nextInt(4),
        id: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }

  void _hitNote(int lane) {
    final noteIndex = _notes.indexWhere((note) => note.lane == lane);
    
    if (noteIndex != -1) {
      setState(() {
        _notes.removeAt(noteIndex);
        _combo++;
        _score += 10 + (_combo * 2);
      });
    } else {
      setState(() {
        _combo = 0;
      });
    }
  }

  void _endGame() {
    _timer?.cancel();
    _noteTimer?.cancel();
    final finalScore = (_score / 10).clamp(0, 100).toInt();
    Navigator.pop(context, finalScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performing at ${widget.venue.name}'),
        backgroundColor: const Color(0xFF16213e),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2a2a3e),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '$_timeLeft s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Score: $_score',
                  style: const TextStyle(
                    color: Color(0xFFe94560),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Combo: x$_combo',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Game Area
          Expanded(
            child: Stack(
              children: [
                // Lanes
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.white24,
                              width: index < 3 ? 1 : 0,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                
                // Notes
                ..._notes.map((note) {
                  return Positioned(
                    left: (MediaQuery.of(context).size.width / 4) * note.lane,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 4,
                      height: 60,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe94560),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 32,
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
            color: const Color(0xFF2a2a3e),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () => _hitNote(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe94560),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
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
    );
  }
}

class _Note {
  final int lane;
  final int id;

  _Note({required this.lane, required this.id});
}
