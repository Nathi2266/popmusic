import 'package:flutter/material.dart';
import '../theme/game_palette.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static const _gold = Color(0xFFFFB347);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = p.primary;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  p.scaffold,
                  p.appBar,
                  p.surface,
                ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(color: accent.withValues(alpha: 0.16), size: 220),
          ),
          Positioned(
            bottom: 80,
            left: -90,
            child: _GlowOrb(color: _gold.withValues(alpha: 0.10), size: 180),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_rounded),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const Spacer(),
                      Text(
                        'CREDITS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                          color: p.textMuted,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [p.text, Color.lerp(p.text, accent, 0.25)!],
                          ).createShader(bounds),
                          child: Text(
                            'POPMUSIC',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: p.text,
                              letterSpacing: 5,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'MUSIC INDUSTRY SIMULATOR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: p.textMuted,
                            letterSpacing: 3.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 48,
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: LinearGradient(
                                colors: [
                                  accent.withValues(alpha: 0.1),
                                  accent,
                                  accent.withValues(alpha: 0.1),
                                ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        _CreditCard(
                          eyebrow: 'CREATED & DEVELOPED BY',
                          title: 'Nkosinathi Radebe',
                          subtitle:
                              'Game design, programming, and production.',
                          highlight: true,
                        ),
                        const SizedBox(height: 16),
                        const _CreditCard(
                          eyebrow: 'STUDIO',
                          title: 'Independent',
                          subtitle:
                              'PopMusic is an original music-industry career sim — write, release, chart, and build a legacy.',
                        ),
                        const SizedBox(height: 16),
                        const _CreditCard(
                          eyebrow: 'SPECIAL THANKS',
                          title: 'Players & testers',
                          subtitle:
                              'To everyone who picked up the mic, chased the charts, and gave this world a spin.',
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'VERSION 1.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.4,
                            color: p.textFaint,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '© 2026 Nkosinathi Radebe\nAll rights reserved.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: p.textFaint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final bool highlight;

  const _CreditCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final gold = p.gold;
    final accent = p.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlight
              ? [
                  Color.lerp(p.surface, gold, 0.12)!,
                  p.surface,
                ]
              : [
                  p.text.withValues(alpha: 0.07),
                  p.text.withValues(alpha: 0.03),
                ],
        ),
        border: Border.all(
          color: highlight
              ? gold.withValues(alpha: 0.38)
              : p.text.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: highlight
                ? gold.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.6,
              color: highlight
                  ? gold.withValues(alpha: 0.9)
                  : p.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: highlight ? 26 : 18,
              fontWeight: FontWeight.w800,
              letterSpacing: highlight ? 0.4 : 0.2,
              color: p.text,
              height: 1.15,
            ),
          ),
          if (highlight) ...[
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: accent.withValues(alpha: 0.85),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
