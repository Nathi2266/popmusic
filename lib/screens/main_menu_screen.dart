// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../utils/animations.dart';
import 'new_game_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'credits_screen.dart';
import '../theme/game_palette.dart';

enum _MenuButtonStyle { primary, accent, ghost, disabled }

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static const _gold = Color(0xFFFFB347);

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateService>(context);
    final canContinue = gameState.canContinue;
    final p = context.palette;
    final accent = p.primary;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // App logo fills every screen size (cover + center crop).
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Container(color: p.scaffold),
            ),
          ),
          // Scrim so menu text/buttons stay readable on any device.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    p.scaffold.withValues(alpha: 0.55),
                    p.scaffold.withValues(alpha: 0.72),
                    p.appBar.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(color: accent.withValues(alpha: 0.18), size: 220),
          ),
          Positioned(
            bottom: 120,
            left: -90,
            child: _GlowOrb(color: _gold.withValues(alpha: 0.12), size: 180),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppAnimations.fadeIn(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [p.text, Color.lerp(p.text, p.primary, 0.25)!],
                              ).createShader(bounds),
                              child: Text(
                                'POPMUSIC',
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w800,
                                  color: p.text,
                                  letterSpacing: 4,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'MUSIC INDUSTRY SIMULATOR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: p.textMuted,
                              letterSpacing: 4,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 56),
                    AppAnimations.slideInUp(
                      duration: const Duration(milliseconds: 500),
                      offset: 40,
                      child: _MenuButton(
                        text: 'NEW GAME',
                        style: _MenuButtonStyle.primary,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewGameScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppAnimations.slideInUp(
                      duration: const Duration(milliseconds: 550),
                      offset: 40,
                      child: _MenuButton(
                        text: 'CONTINUE',
                        style: canContinue
                            ? _MenuButtonStyle.accent
                            : _MenuButtonStyle.disabled,
                        onPressed: canContinue
                            ? () async {
                                final ok = await gameState.continueOrResume();
                                if (!context.mounted) return;
                                if (!ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not load saved game'),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GameScreen(),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppAnimations.slideInUp(
                      duration: const Duration(milliseconds: 600),
                      offset: 40,
                      child: _MenuButton(
                        text: 'SETTINGS',
                        style: _MenuButtonStyle.primary,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppAnimations.slideInUp(
                      duration: const Duration(milliseconds: 650),
                      offset: 40,
                      child: _MenuButton(
                        text: 'CREDITS',
                        style: _MenuButtonStyle.primary,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreditsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppAnimations.slideInUp(
                      duration: const Duration(milliseconds: 700),
                      offset: 40,
                      child: _MenuButton(
                        text: 'EXIT',
                        style: _MenuButtonStyle.ghost,
                        onPressed: () => SystemNavigator.pop(),
                      ),
                    ),
                  ],
                ),
              ),
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

class _MenuButton extends StatefulWidget {
  final String text;
  final _MenuButtonStyle style;
  final VoidCallback? onPressed;

  const _MenuButton({
    required this.text,
    required this.style,
    this.onPressed,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _pressed = false;

  bool get _isEnabled =>
      widget.onPressed != null && widget.style != _MenuButtonStyle.disabled;

  void _handleTapDown(TapDownDetails _) {
    if (!_isEnabled) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isEnabled) return;
    setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : 1.0;
    final colors = _resolveColors();

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 300,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: colors.backgroundGradient,
            border: Border.all(
              color: colors.borderColor,
              width: 1.2,
            ),
            boxShadow: colors.shadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              children: [
                if (colors.showSheen)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 26,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.16),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.4,
                      color: colors.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _MenuButtonColors _resolveColors() {
    final p = context.palette;
    switch (widget.style) {
      case _MenuButtonStyle.primary:
        return _MenuButtonColors(
          backgroundGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(p.primary, Colors.white, 0.2)!,
              p.primary,
              Color.lerp(p.primary, Colors.black, 0.2)!,
            ],
          ),
          borderColor: Colors.white.withValues(alpha: 0.22),
          textColor: Colors.white,
          showSheen: true,
          shadows: [
            BoxShadow(
              color: p.primary.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case _MenuButtonStyle.accent:
        return _MenuButtonColors(
          backgroundGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFD085),
              MainMenuScreen._gold,
              const Color(0xFFE69500),
            ],
          ),
          borderColor: Colors.white.withValues(alpha: 0.24),
          textColor: const Color(0xFF1A1208),
          showSheen: true,
          shadows: [
            BoxShadow(
              color: MainMenuScreen._gold.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case _MenuButtonStyle.ghost:
        return _MenuButtonColors(
          backgroundGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              p.text.withValues(alpha: 0.06),
              p.text.withValues(alpha: 0.02),
            ],
          ),
          borderColor: p.text.withValues(alpha: 0.14),
          textColor: p.text.withValues(alpha: 0.82),
          showSheen: false,
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case _MenuButtonStyle.disabled:
        return _MenuButtonColors(
          backgroundGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              p.text.withValues(alpha: 0.04),
              p.text.withValues(alpha: 0.02),
            ],
          ),
          borderColor: p.text.withValues(alpha: 0.08),
          textColor: p.text.withValues(alpha: 0.28),
          showSheen: false,
          shadows: const [],
        );
    }
  }
}

class _MenuButtonColors {
  final Gradient backgroundGradient;
  final Color borderColor;
  final Color textColor;
  final bool showSheen;
  final List<BoxShadow> shadows;

  const _MenuButtonColors({
    required this.backgroundGradient,
    required this.borderColor,
    required this.textColor,
    required this.showSheen,
    required this.shadows,
  });
}
