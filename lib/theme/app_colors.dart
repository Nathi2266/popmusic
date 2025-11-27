import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFe94560);
  static const Color primaryDark = Color(0xFFc7354d);
  static const Color primaryLight = Color(0xFFf05a75);

  // Background Colors
  static const Color background = Color(0xFF1a1a2e);
  static const Color backgroundSecondary = Color(0xFF16213e);
  static const Color backgroundTertiary = Color(0xFF0f3460);
  static const Color surface = Color(0xFF2a2a3e);
  static const Color surfaceLight = Color(0xFF3a3a4e);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textDisabled = Color(0xFF606060);

  // Accent Colors
  static const Color accent = Color(0xFF9C27B0);
  static const Color accentLight = Color(0xFFBA68C8);
  static const Color accentDark = Color(0xFF7B1FA2);

  // Status Colors
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundSecondary, backgroundTertiary],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  // Status-based colors
  static Color getStaminaColor(double stamina) {
    if (stamina >= 70) return success;
    if (stamina >= 40) return warning;
    return error;
  }

  static Color getPopularityColor(double popularity) {
    if (popularity >= 80) return gold;
    if (popularity >= 60) return success;
    if (popularity >= 40) return info;
    if (popularity >= 20) return warning;
    return textTertiary;
  }

  static Color getAttributeColor(String attribute) {
    switch (attribute.toLowerCase()) {
      case 'popularity':
        return primary;
      case 'reputation':
        return success;
      case 'performance':
        return info;
      case 'talent':
        return warning;
      case 'production':
        return accent;
      case 'songwriting':
        return const Color(0xFF00BCD4);
      case 'charisma':
        return const Color(0xFFFFEB3B);
      case 'marketing':
        return const Color(0xFF8BC34A);
      case 'networking':
        return const Color(0xFF03A9F4);
      case 'creativity':
        return const Color(0xFFE91E63);
      case 'discipline':
        return const Color(0xFF607D8B);
      case 'stamina':
        return getStaminaColor(50); // Default value
      case 'controversy':
        return error;
      case 'wealth':
        return gold;
      case 'influence':
        return accent;
      default:
        return textSecondary;
    }
  }
}

