import 'package:flutter/material.dart';
import 'colors.dart';

/// Kids AI Typografie
/// Gut lesbare, kindgerechte Schriften
class KidsTypography {
  KidsTypography._();

  // ============================================================
  // FONT FAMILIES
  // ============================================================

  /// Primäre Schrift (System-Font, gut lesbar)
  static const String fontFamily = 'Nunito';

  /// Alternative: System-Font falls Nunito nicht verfügbar
  static const String fontFamilyFallback = '.SF Pro Rounded';

  // ============================================================
  // DISPLAY STYLES (für große Überschriften)
  // ============================================================

  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: KidsColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.25,
    color: KidsColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.3,
    color: KidsColors.textPrimary,
  );

  // ============================================================
  // HEADLINE STYLES (für Abschnitte)
  // ============================================================

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.35,
    color: KidsColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.4,
    color: KidsColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: KidsColors.textPrimary,
  );

  // ============================================================
  // TITLE STYLES (für Cards, Listen)
  // ============================================================

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: KidsColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.45,
    color: KidsColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.45,
    color: KidsColors.textPrimary,
  );

  // ============================================================
  // BODY STYLES (für Fließtext)
  // ============================================================

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
    color: KidsColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
    color: KidsColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: KidsColors.textSecondary,
  );

  // ============================================================
  // LABEL STYLES (für Buttons, Chips)
  // ============================================================

  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: KidsColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: KidsColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: KidsColors.textSecondary,
  );

  // ============================================================
  // SPECIAL STYLES
  // ============================================================

  /// Für Spielpunkte, große Zahlen
  static const TextStyle score = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.1,
    color: KidsColors.primary,
  );

  /// Für Timer, Countdown
  static const TextStyle timer = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
    color: KidsColors.textPrimary,
  );

  /// Für Untertitel (Lianko App)
  static const TextStyle subtitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.6,
    color: KidsColors.textPrimary,
    backgroundColor: Color(0xCC000000), // Halbtransparent
  );

  // ============================================================
  // TEXT THEME (für ThemeData)
  // ============================================================

  static TextTheme get textTheme => const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
