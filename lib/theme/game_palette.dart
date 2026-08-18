import 'package:flutter/material.dart';

enum AppThemeId {
  light,
  dark,
  midnight,
  neon,
  sunset,
  ocean;

  String get storageName => name;

  String get displayName => switch (this) {
        AppThemeId.light => 'Light',
        AppThemeId.dark => 'Dark',
        AppThemeId.midnight => 'Midnight',
        AppThemeId.neon => 'Neon',
        AppThemeId.sunset => 'Sunset',
        AppThemeId.ocean => 'Ocean',
      };

  String get blurb => switch (this) {
        AppThemeId.light => 'Bright studio. Dark text on pale surfaces.',
        AppThemeId.dark => 'Classic PopMusic nightclub navy.',
        AppThemeId.midnight => 'Near-black stage. Low glare.',
        AppThemeId.neon => 'Cyan and magenta on pitch black.',
        AppThemeId.sunset => 'Warm dusk. Coral and gold.',
        AppThemeId.ocean => 'Deep teal. Cool radio-studio blue.',
      };

  IconData get icon => switch (this) {
        AppThemeId.light => Icons.light_mode,
        AppThemeId.dark => Icons.dark_mode,
        AppThemeId.midnight => Icons.nights_stay,
        AppThemeId.neon => Icons.bolt,
        AppThemeId.sunset => Icons.wb_twilight,
        AppThemeId.ocean => Icons.water,
      };

  static AppThemeId fromName(String? name) {
    switch (name) {
      case 'light':
        return AppThemeId.light;
      case 'darker':
      case 'midnight':
        return AppThemeId.midnight;
      case 'neon':
        return AppThemeId.neon;
      case 'sunset':
        return AppThemeId.sunset;
      case 'ocean':
        return AppThemeId.ocean;
      default:
        return AppThemeId.dark;
    }
  }
}

@immutable
class GamePalette extends ThemeExtension<GamePalette> {
  final Color scaffold;
  final Color appBar;
  final Color surface;
  final Color card;
  final Color primary;
  final Color gold;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color divider;
  final Color navBar;
  final Color glow;

  const GamePalette({
    required this.scaffold,
    required this.appBar,
    required this.surface,
    required this.card,
    required this.primary,
    required this.gold,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.divider,
    required this.navBar,
    required this.glow,
  });

  static const dark = GamePalette(
    scaffold: Color(0xFF1a1a2e),
    appBar: Color(0xFF16213e),
    surface: Color(0xFF2a2a3e),
    card: Color(0xFF2a2a3e),
    primary: Color(0xFFe94560),
    gold: Color(0xFFFFD700),
    text: Colors.white,
    textMuted: Color(0xFFB0B0C0),
    textFaint: Color(0xFF808090),
    divider: Color(0x33FFFFFF),
    navBar: Color(0xFF16213e),
    glow: Color(0xFFe94560),
  );

  static const light = GamePalette(
    scaffold: Color(0xFFF4F1EA),
    appBar: Color(0xFFFFFBFF),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFFC6284A),
    gold: Color(0xFFB8860B),
    text: Color(0xFF1A1A2E),
    textMuted: Color(0xFF5A5A6E),
    textFaint: Color(0xFF8A8A9A),
    divider: Color(0x331A1A2E),
    navBar: Color(0xFFFFFBFF),
    glow: Color(0xFFC6284A),
  );

  static const midnight = GamePalette(
    scaffold: Color(0xFF07070C),
    appBar: Color(0xFF0C0C14),
    surface: Color(0xFF16161F),
    card: Color(0xFF16161F),
    primary: Color(0xFFe94560),
    gold: Color(0xFFFFD54F),
    text: Color(0xFFF2F2F8),
    textMuted: Color(0xFFA8A8B8),
    textFaint: Color(0xFF6E6E80),
    divider: Color(0x22FFFFFF),
    navBar: Color(0xFF0C0C14),
    glow: Color(0xFFe94560),
  );

  static const neon = GamePalette(
    scaffold: Color(0xFF050510),
    appBar: Color(0xFF0A0A1A),
    surface: Color(0xFF121228),
    card: Color(0xFF121228),
    primary: Color(0xFF00E5FF),
    gold: Color(0xFF76FF03),
    text: Color(0xFFE8FFFF),
    textMuted: Color(0xFF90CAF9),
    textFaint: Color(0xFF5C6BC0),
    divider: Color(0x3300E5FF),
    navBar: Color(0xFF0A0A1A),
    glow: Color(0xFFFF00E5),
  );

  static const sunset = GamePalette(
    scaffold: Color(0xFF2A1420),
    appBar: Color(0xFF3D1A28),
    surface: Color(0xFF4A2434),
    card: Color(0xFF4A2434),
    primary: Color(0xFFFF6B4A),
    gold: Color(0xFFFFB347),
    text: Color(0xFFFFF6EE),
    textMuted: Color(0xFFE8C9B8),
    textFaint: Color(0xFFC4A090),
    divider: Color(0x33FFB347),
    navBar: Color(0xFF3D1A28),
    glow: Color(0xFFFF6B4A),
  );

  static const ocean = GamePalette(
    scaffold: Color(0xFF0B1F2A),
    appBar: Color(0xFF12303D),
    surface: Color(0xFF1A3D4D),
    card: Color(0xFF1A3D4D),
    primary: Color(0xFF26C6DA),
    gold: Color(0xFF4FC3F7),
    text: Color(0xFFECFBFF),
    textMuted: Color(0xFFB0E0EC),
    textFaint: Color(0xFF7AA8B4),
    divider: Color(0x3326C6DA),
    navBar: Color(0xFF12303D),
    glow: Color(0xFF26C6DA),
  );

  static GamePalette forId(AppThemeId id) => switch (id) {
        AppThemeId.light => light,
        AppThemeId.dark => dark,
        AppThemeId.midnight => midnight,
        AppThemeId.neon => neon,
        AppThemeId.sunset => sunset,
        AppThemeId.ocean => ocean,
      };

  Brightness get brightness =>
      ThemeData.estimateBrightnessForColor(scaffold);

  bool get isLight => brightness == Brightness.light;

  /// Readable fill overlay (replaces hardcoded white washes).
  Color wash(double alpha) => text.withValues(alpha: alpha);

  /// Text/icon color that contrasts with [background] (banners, chips).
  static Color contrastOn(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : const Color(0xFF1A1A2E);
  }

  static Color contrastOnMuted(Color background) =>
      contrastOn(background).withValues(alpha: 0.78);

  @override
  GamePalette copyWith({
    Color? scaffold,
    Color? appBar,
    Color? surface,
    Color? card,
    Color? primary,
    Color? gold,
    Color? text,
    Color? textMuted,
    Color? textFaint,
    Color? divider,
    Color? navBar,
    Color? glow,
  }) {
    return GamePalette(
      scaffold: scaffold ?? this.scaffold,
      appBar: appBar ?? this.appBar,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      primary: primary ?? this.primary,
      gold: gold ?? this.gold,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      divider: divider ?? this.divider,
      navBar: navBar ?? this.navBar,
      glow: glow ?? this.glow,
    );
  }

  @override
  GamePalette lerp(ThemeExtension<GamePalette>? other, double t) {
    if (other is! GamePalette) return this;
    return GamePalette(
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      appBar: Color.lerp(appBar, other.appBar, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

extension GamePaletteX on BuildContext {
  GamePalette get palette =>
      Theme.of(this).extension<GamePalette>() ?? GamePalette.dark;
}
