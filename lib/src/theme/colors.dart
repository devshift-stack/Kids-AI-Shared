import 'package:flutter/material.dart';

/// Kids AI App Colors
/// Einheitliche Farbpalette für alle Apps
class KidsColors {
  KidsColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF5048CC);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFF8FA3);
  static const Color secondaryDark = Color(0xFFCC516A);

  // Accent
  static const Color accent = Color(0xFF00D9FF);
  static const Color accentLight = Color(0xFF66E8FF);
  static const Color accentDark = Color(0xFF00ADCC);

  // Background & Surface
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F2FF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color error = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFF8A80);
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningLight = Color(0xFFFFCC80);
  static const Color info = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9094A6);
  static const Color textLight = Colors.white;
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Age Group Colors (für altersgerechte UI)
  static const Color preschool = Color(0xFFFFB347);    // 3-5 Jahre: Warm Orange
  static const Color earlySchool = Color(0xFF87CEEB);  // 6-8 Jahre: Sky Blue
  static const Color lateSchool = Color(0xFF98D8C8);   // 9-12 Jahre: Mint Green

  // Game Category Colors
  static const Color lettersGame = Color(0xFF6C63FF);
  static const Color numbersGame = Color(0xFFFF6584);
  static const Color colorsGame = Color(0xFFFFB347);
  static const Color shapesGame = Color(0xFF00D9FF);
  static const Color animalsGame = Color(0xFF4CAF50);
  static const Color storiesGame = Color(0xFF9C27B0);

  // Leaderboard Colors
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  /// Gibt Farbe basierend auf Alter zurück
  static Color getAgeColor(int age) {
    if (age <= 5) return preschool;
    if (age <= 8) return earlySchool;
    return lateSchool;
  }

  /// Gibt Game-Kategorie Farbe zurück
  static Color getGameColor(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'letters':
      case 'buchstaben':
      case 'slova':
        return lettersGame;
      case 'numbers':
      case 'zahlen':
      case 'brojevi':
        return numbersGame;
      case 'colors':
      case 'farben':
      case 'boje':
        return colorsGame;
      case 'shapes':
      case 'formen':
      case 'oblici':
        return shapesGame;
      case 'animals':
      case 'tiere':
      case 'životinje':
        return animalsGame;
      case 'stories':
      case 'geschichten':
      case 'priče':
        return storiesGame;
      default:
        return primary;
    }
  }
}
