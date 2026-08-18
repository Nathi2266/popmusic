import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popmusic/theme/app_theme.dart';
import 'package:popmusic/theme/game_palette.dart';

void main() {
  test('legacy darker theme maps to midnight', () {
    expect(AppThemeId.fromName('darker'), AppThemeId.midnight);
    expect(AppThemeId.fromName('midnight'), AppThemeId.midnight);
  });

  test('every theme id builds Material ThemeData with palette extension', () {
    for (final id in AppThemeId.values) {
      final theme = AppTheme.fromId(id);
      final palette = theme.extension<GamePalette>();
      expect(palette, isNotNull, reason: id.name);
      expect(palette, GamePalette.forId(id));
      expect(
        theme.brightness,
        ThemeData.estimateBrightnessForColor(palette!.scaffold),
      );
    }
  });

      test('light theme uses light brightness and dark text', () {
    final theme = AppTheme.fromId(AppThemeId.light);
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.onSurface, GamePalette.light.text);
    expect(GamePalette.contrastOn(Colors.white), const Color(0xFF1A1A2E));
    expect(GamePalette.contrastOn(const Color(0xFF1A1A2E)), Colors.white);
  });
}
