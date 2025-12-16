import 'package:flutter/material.dart';

/// Kids AI Farbpalette
/// Fröhliche, kindgerechte Farben für beide Apps (Alanko & Lianko)
class KidsColors {
  KidsColors._();

  // ============================================================
  // PRIMARY COLORS
  // ============================================================

  /// Hauptfarbe - Freundliches Violett
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9B8FF2);
  static const Color primaryDark = Color(0xFF4A3FC4);

  /// Sekundärfarbe - Fröhliches Türkis
  static const Color secondary = Color(0xFF00CEC9);
  static const Color secondaryLight = Color(0xFF55E6E3);
  static const Color secondaryDark = Color(0xFF00A8A5);

  /// Akzentfarbe - Warmes Orange
  static const Color accent = Color(0xFFFDAA4C);
  static const Color accentLight = Color(0xFFFFBE71);
  static const Color accentDark = Color(0xFFE88E2E);

  // ============================================================
  // FEEDBACK COLORS
  // ============================================================

  /// Erfolg - Grün
  static const Color success = Color(0xFF00B894);
  static const Color successLight = Color(0xFF55D4B8);
  static const Color successBg = Color(0xFFE8F8F5);

  /// Fehler - Sanftes Rot (nicht aggressiv für Kinder)
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFF9999);
  static const Color errorBg = Color(0xFFFEECEC);

  /// Warnung - Gelb
  static const Color warning = Color(0xFFFFC312);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningBg = Color(0xFFFFF9E6);

  /// Info - Blau
  static const Color info = Color(0xFF74B9FF);
  static const Color infoLight = Color(0xFFA4CFFF);
  static const Color infoBg = Color(0xFFEBF5FF);

  // ============================================================
  // NEUTRAL COLORS
  // ============================================================

  /// Hintergrund
  static const Color background = Color(0xFFF8F9FE);
  static const Color backgroundAlt = Color(0xFFFFFFFF);

  /// Oberflächen
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F8);

  /// Text
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textMuted = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  /// Borders & Dividers
  static const Color border = Color(0xFFE0E6ED);
  static const Color borderLight = Color(0xFFF0F2F8);
  static const Color divider = Color(0xFFEEF2F6);

  // ============================================================
  // SPECIAL COLORS (für Gamification)
  // ============================================================

  /// Sterne & Belohnungen
  static const Color star = Color(0xFFFFD700);
  static const Color starOutline = Color(0xFFDAA520);

  /// Level & Fortschritt
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color diamond = Color(0xFFB9F2FF);

  /// Avatar-Hintergründe
  static const List<Color> avatarColors = [
    Color(0xFF6C5CE7), // Violett
    Color(0xFF00CEC9), // Türkis
    Color(0xFFFDAA4C), // Orange
    Color(0xFFFF6B6B), // Koralle
    Color(0xFF74B9FF), // Hellblau
    Color(0xFF55E6C1), // Mint
    Color(0xFFFF85A2), // Rosa
    Color(0xFFA29BFE), // Lavendel
  ];

  // ============================================================
  // DARK THEME COLORS (für Parent Dashboard)
  // ============================================================

  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF252542);
  static const Color darkSurfaceVariant = Color(0xFF2D2D4A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0C0);
  static const Color darkTextMuted = Color(0xFF6E6E80);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Gibt eine zufällige Avatar-Farbe zurück
  static Color randomAvatarColor() {
    return avatarColors[DateTime.now().millisecond % avatarColors.length];
  }

  /// Gibt Avatar-Farbe basierend auf Index zurück
  static Color avatarColorAt(int index) {
    return avatarColors[index % avatarColors.length];
  }

  /// Erzeugt MaterialColor aus einer Farbe
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final swatch = <int, Color>{};
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }
}
