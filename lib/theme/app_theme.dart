import 'package:flutter/material.dart';
import 'game_palette.dart';

class AppTheme {
  static const String fontFamily = 'Poppins';

  static TextTheme getTextTheme(Color textColor) {
    final base = TextStyle(
      fontFamily: fontFamily,
      color: textColor,
      decorationColor: textColor,
    );
    return TextTheme(
      displayLarge: base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displaySmall: base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      headlineLarge: base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      headlineMedium: base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineSmall: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleLarge: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleMedium: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyLarge: base.copyWith(
        fontSize: 16,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: base.copyWith(
        fontSize: 14,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: base.copyWith(
        fontSize: 12,
        letterSpacing: 0.4,
        height: 1.5,
      ),
      labelLarge: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelSmall: base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      ),
    );
  }

  static ThemeData fromId(AppThemeId id) => fromPalette(GamePalette.forId(id));

  static ThemeData getDarkTheme() => fromId(AppThemeId.dark);

  static ThemeData fromPalette(GamePalette p) {
    final brightness = p.brightness;
    final onPrimary = ThemeData.estimateBrightnessForColor(p.primary) ==
            Brightness.dark
        ? Colors.white
        : const Color(0xFF101018);
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: onPrimary,
      secondary: p.gold,
      onSecondary: brightness == Brightness.dark
          ? const Color(0xFF1A1A2E)
          : Colors.white,
      error: const Color(0xFFF44336),
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.scaffold,
      canvasColor: p.scaffold,
      cardColor: p.card,
      dividerColor: p.divider,
      textTheme: getTextTheme(p.text),
      primaryTextTheme: getTextTheme(p.text),
      iconTheme: IconThemeData(color: p.text),
      primaryIconTheme: IconThemeData(color: p.text),
      appBarTheme: AppBarTheme(
        backgroundColor: p.appBar,
        foregroundColor: p.text,
        elevation: 0,
        iconTheme: IconThemeData(color: p.text),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: p.textMuted,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: p.scaffold,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.navBar,
        selectedItemColor: p.primary,
        unselectedItemColor: p.textFaint,
        type: BottomNavigationBarType.fixed,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textMuted,
        textColor: p.text,
        subtitleTextStyle: TextStyle(color: p.textMuted, fontSize: 13),
        titleTextStyle: TextStyle(
          color: p.text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        disabledColor: p.surface,
        selectedColor: p.primary.withValues(alpha: 0.24),
        labelStyle: TextStyle(color: p.text, fontSize: 12),
        secondaryLabelStyle: TextStyle(color: onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: p.divider),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return p.textFaint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return p.primary.withValues(alpha: 0.45);
          }
          return p.divider;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        thumbColor: p.primary,
        inactiveTrackColor: p.divider,
        overlayColor: p.primary.withValues(alpha: 0.16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          side: BorderSide(color: p.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: TextStyle(color: p.textFaint),
        labelStyle: TextStyle(color: p.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dividerTheme: DividerThemeData(color: p.divider, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surface,
        contentTextStyle: TextStyle(color: p.text),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.appBar,
        modalBackgroundColor: p.appBar,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      extensions: [p],
    );
  }
}
