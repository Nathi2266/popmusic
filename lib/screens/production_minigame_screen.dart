import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../widgets/glass_card.dart';

class ProductionMinigameScreen extends StatefulWidget {
  const ProductionMinigameScreen({super.key});

  @override
  State<ProductionMinigameScreen> createState() =>
      _ProductionMinigameScreenState();
}

class _ProductionMinigameScreenState extends State<ProductionMinigameScreen>
    with SingleTickerProviderStateMixin {
  double _bass = 50;
  double _treble = 50;
  double _volume = 50;
  double _mid = 50;
  int _score = 0;
  int _timeLeft = 30;
  Timer? _timer;
  int _difficulty = 1;
  
  double _targetBass = 50;
  double _targetTreble = 50;
  double _targetVolume = 50;
  double _targetMid = 50;

  late AnimationController _waveformController;
  final List<double> _waveformData = List.generate(50, (_) => Random().nextDouble() * 100);

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _generateNewTarget();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveformController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _timeLeft = _difficulty == 1 ? 45 : _difficulty == 2 ? 30 : 20;
      _score = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        } else if (_timeLeft % (6 - _difficulty) == 0) {
          _checkAccuracy();
          _generateNewTarget();
        }
      });
    });
  }

  void _generateNewTarget() {
    final random = Random();
    final range = _difficulty == 1 ? 30.0 : _difficulty == 2 ? 20.0 : 10.0;
    setState(() {
      _targetBass = 30 + random.nextDouble() * range;
      _targetTreble = 30 + random.nextDouble() * range;
      _targetVolume = 30 + random.nextDouble() * range;
      _targetMid = 30 + random.nextDouble() * range;
    });
  }

  void _checkAccuracy() {
    final bassAccuracy = 100 - ((_bass - _targetBass).abs() / 100 * 100);
    final trebleAccuracy = 100 - ((_treble - _targetTreble).abs() / 100 * 100);
    final volumeAccuracy = 100 - ((_volume - _targetVolume).abs() / 100 * 100);
    final midAccuracy = 100 - ((_mid - _targetMid).abs() / 100 * 100);
    
    final avgAccuracy = (bassAccuracy + trebleAccuracy + volumeAccuracy + midAccuracy) / 4;
    final multiplier = _difficulty == 1 ? 1.0 : _difficulty == 2 ? 1.5 : 2.0;
    
    setState(() {
      _score += (avgAccuracy * multiplier).toInt();
    });
  }

  void _endGame() {
    _timer?.cancel();
    final finalScore = (_score / (6 - _difficulty)).clamp(0, 100).toInt();
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Stats and Difficulty
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
                              const Text(
                                'Difficulty',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              Text(
                                _difficulty == 1 ? 'Easy' : _difficulty == 2 ? 'Medium' : 'Hard',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_timeLeft == (_difficulty == 1 ? 45 : _difficulty == 2 ? 30 : 20))
                            DropdownButton<int>(
                              value: _difficulty,
                              dropdownColor: const Color(0xFF2a2a3e),
                              style: const TextStyle(color: Colors.white),
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
                          const Icon(Icons.timer, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$_timeLeft s',
                            style: const TextStyle(
                              color: Colors.white,
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
                        style: const TextStyle(
                          color: Color(0xFFe94560),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Waveform Visualization
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Waveform',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: AnimatedBuilder(
                        animation: _waveformController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _WaveformPainter(_waveformData, _waveformController.value),
                            size: Size.infinite,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                      _MixerControl(
                        label: 'Mid',
                        value: _mid,
                        targetValue: _targetMid,
                        onChanged: (value) {
                          setState(() {
                            _mid = value;
                          });
                        },
                        color: const Color(0xFF9C27B0),
                      ),
                      const SizedBox(height: 24),
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _endGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  double _getAccuracy() {
    return 100 - ((value - targetValue).abs() / 100 * 100);
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = _getAccuracy();
    final isClose = accuracy > 80;
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: isClose ? color : Colors.white24,
      borderWidth: isClose ? 2 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Target: ${targetValue.toInt()}',
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Accuracy: ${accuracy.toInt()}%',
                    style: TextStyle(
                      color: isClose ? const Color(0xFF4CAF50) : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              // Target indicator
              Positioned(
                left: targetValue / 100 * (MediaQuery.of(context).size.width - 64) - 2,
                child: Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withAlpha((255 * 0.7).round()),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Slider
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: color,
                  inactiveTrackColor: const Color(0xFF2a2a3e),
                  thumbColor: color,
                  overlayColor: color.withAlpha((255 * 0.2).round()),
                  trackHeight: 10,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;
  final double animationValue;

  _WaveformPainter(this.data, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFe94560)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final xStep = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - (data[i] / 100 * size.height);
      final animatedY = y + (sin(animationValue * 2 * pi + i * 0.1) * 5);

      if (i == 0) {
        path.moveTo(x, animatedY);
      } else {
        path.lineTo(x, animatedY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
