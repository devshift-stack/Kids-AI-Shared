import 'package:flutter/material.dart';
import 'colors.dart';

/// Kids AI Gradienten und Schatten
/// Für lebendige, spielerische Oberflächen
class KidsGradients {
  KidsGradients._();

  // ============================================================
  // PRIMARY GRADIENTS
  // ============================================================

  /// Haupt-Gradient (Violett)
  static const LinearGradient primary = LinearGradient(
    colors: [KidsColors.primary, KidsColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sekundär-Gradient (Türkis)
  static const LinearGradient secondary = LinearGradient(
    colors: [KidsColors.secondary, KidsColors.secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Akzent-Gradient (Orange)
  static const LinearGradient accent = LinearGradient(
    colors: [KidsColors.accent, KidsColors.accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // SPECIAL GRADIENTS
  // ============================================================

  /// Erfolgs-Gradient
  static const LinearGradient success = LinearGradient(
    colors: [KidsColors.success, Color(0xFF55E6C1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sonnenuntergang (warm)
  static const LinearGradient sunset = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFDAA4C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Ozean (kühl)
  static const LinearGradient ocean = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Regenbogen (fröhlich)
  static const LinearGradient rainbow = LinearGradient(
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFDAA4C),
      Color(0xFFFFC312),
      Color(0xFF00B894),
      Color(0xFF00CEC9),
      Color(0xFF6C5CE7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold (für Belohnungen)
  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================================
  // BACKGROUND GRADIENTS
  // ============================================================

  /// Hintergrund-Gradient (subtil)
  static const LinearGradient background = LinearGradient(
    colors: [Color(0xFFF8F9FE), Color(0xFFEEF2F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Header-Gradient
  static const LinearGradient header = LinearGradient(
    colors: [KidsColors.primary, KidsColors.primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Dark Header (Parent Dashboard)
  static const LinearGradient darkHeader = LinearGradient(
    colors: [KidsColors.darkBackground, KidsColors.darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================================
  // RADIAL GRADIENTS
  // ============================================================

  /// Spotlight-Effekt
  static RadialGradient spotlight(Color color) {
    return RadialGradient(
      colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)],
      radius: 0.8,
    );
  }

  /// Glow-Effekt
  static RadialGradient glow(Color color) {
    return RadialGradient(
      colors: [color, color.withValues(alpha: 0)],
      stops: const [0.0, 1.0],
      radius: 0.5,
    );
  }
}

/// Kids AI Schatten
class KidsShadows {
  KidsShadows._();

  // ============================================================
  // BOX SHADOWS
  // ============================================================

  /// Kein Schatten
  static const List<BoxShadow> none = [];

  /// Subtiler Schatten
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Mittlerer Schatten
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Großer Schatten
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  /// Extra großer Schatten (für Modals)
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // ============================================================
  // COLORED SHADOWS
  // ============================================================

  /// Primärfarben-Schatten
  static List<BoxShadow> primary = [
    BoxShadow(
      color: KidsColors.primary.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  /// Erfolgs-Schatten
  static List<BoxShadow> success = [
    BoxShadow(
      color: KidsColors.success.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  /// Akzent-Schatten
  static List<BoxShadow> accent = [
    BoxShadow(
      color: KidsColors.accent.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // ============================================================
  // INNER SHADOWS (für gedrückte Buttons)
  // ============================================================

  static List<BoxShadow> innerSm = const [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];
}
