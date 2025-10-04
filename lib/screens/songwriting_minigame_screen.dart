import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SongwritingMinigameScreen extends StatefulWidget {
  const SongwritingMinigameScreen({super.key});

  @override
  State<SongwritingMinigameScreen> createState() =>
      _SongwritingMinigameScreenState();
}

class _SongwritingMinigameScreenState extends State<SongwritingMinigameScreen> {
  final List<String> _words = [
    'love', 'heart', 'night', 'dream', 'fire', 'soul', 'light', 'time',
    'dance', 'feel', 'shine', 'star', 'moon', 'sky', 'rain', 'sun'
  ];
  
  final List<String> _selectedWords = [];
  int _score = 0;
  int _timeLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _timeLeft = 30;
      _score = 0;
      _selectedWords.clear();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    final finalScore = (_score * 3.33).clamp(0, 100).toInt();
    Navigator.pop(context, finalScore);
  }

  void _selectWord(String word) {
    if (_selectedWords.length < 8) {
      setState(() {
        _selectedWords.add(word);
        _score += 5;
      });
    }
  }

  void _removeWord(int index) {
    setState(() {
      _selectedWords.removeAt(index);
      _score = max(0, _score - 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Songwriting'),
        backgroundColor: const Color(0xFF16213e),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer and Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a3e),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a3e),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(
                      color: Color(0xFFe94560),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Instructions
            const Text(
              'Create lyrics by selecting words!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),

            // Selected Words
            Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2a2a3e),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedWords.isEmpty
                  ? const Center(
                      child: Text(
                        'Select words to build your lyrics',
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedWords.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _removeWord(entry.key),
                          child: Chip(
                            label: Text(entry.value),
                            backgroundColor: const Color(0xFFe94560),
                            labelStyle: const TextStyle(color: Colors.white),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                            onDeleted: () => _removeWord(entry.key),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 24),

            // Word Selection
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2,
                ),
                itemCount: _words.length,
                itemBuilder: (context, index) {
                  final word = _words[index];
                  return ElevatedButton(
                    onPressed: () => _selectWord(word),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2a2a3e),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      word,
                      style: const TextStyle(fontSize: 16),
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
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
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
    );
  }
}
