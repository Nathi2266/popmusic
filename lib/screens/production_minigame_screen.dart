import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ProductionMinigameScreen extends StatefulWidget {
  const ProductionMinigameScreen({super.key});

  @override
  State<ProductionMinigameScreen> createState() =>
      _ProductionMinigameScreenState();
}

class _ProductionMinigameScreenState extends State<ProductionMinigameScreen> {
  double _bass = 50;
  double _treble = 50;
  double _volume = 50;
  int _score = 0;
  int _timeLeft = 30;
  Timer? _timer;
  
  double _targetBass = 50;
  double _targetTreble = 50;
  double _targetVolume = 50;

  @override
  void initState() {
    super.initState();
    _generateNewTarget();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        } else if (_timeLeft % 5 == 0) {
          _checkAccuracy();
          _generateNewTarget();
        }
      });
    });
  }

  void _generateNewTarget() {
    final random = Random();
    setState(() {
      _targetBass = 20 + random.nextDouble() * 60;
      _targetTreble = 20 + random.nextDouble() * 60;
      _targetVolume = 20 + random.nextDouble() * 60;
    });
  }

  void _checkAccuracy() {
    final bassAccuracy = 100 - ((_bass - _targetBass).abs() / 100 * 100);
    final trebleAccuracy = 100 - ((_treble - _targetTreble).abs() / 100 * 100);
    final volumeAccuracy = 100 - ((_volume - _targetVolume).abs() / 100 * 100);
    
    final avgAccuracy = (bassAccuracy + trebleAccuracy + volumeAccuracy) / 3;
    
    setState(() {
      _score += avgAccuracy.toInt();
    });
  }

  void _endGame() {
    _timer?.cancel();
    final finalScore = (_score / 6).clamp(0, 100).toInt();
    Navigator.pop(context, finalScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production'),
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

            const Text(
              'Match the target levels!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 32),

            // Bass Control
            _MixerControl(
              label: 'Bass',
              value: _bass,
              targetValue: _targetBass,
              onChanged: (value) {
                setState(() {
                  _bass = value;
                });
              },
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 24),

            // Treble Control
            _MixerControl(
              label: 'Treble',
              value: _treble,
              targetValue: _targetTreble,
              onChanged: (value) {
                setState(() {
                  _treble = value;
                });
              },
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 24),

            // Volume Control
            _MixerControl(
              label: 'Volume',
              value: _volume,
              targetValue: _targetVolume,
              onChanged: (value) {
                setState(() {
                  _volume = value;
                });
              },
              color: const Color(0xFF4CAF50),
            ),
            const Spacer(),

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

class _MixerControl extends StatelessWidget {
  final String label;
  final double value;
  final double targetValue;
  final ValueChanged<double> onChanged;
  final Color color;

  const _MixerControl({
    required this.label,
    required this.value,
    required this.targetValue,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Target: ${targetValue.toInt()}',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            // Target indicator
            Positioned(
              left: targetValue / 100 * (MediaQuery.of(context).size.width - 32) - 2,
              child: Container(
                width: 4,
                height: 40,
                color: color.withAlpha((255 * 0.5).round()),
              ),
            ),
            // Slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: const Color(0xFF2a2a3e),
                thumbColor: color,
                overlayColor: color.withAlpha((255 * 0.2).round()),
                trackHeight: 8,
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        Text(
          '${value.toInt()}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
