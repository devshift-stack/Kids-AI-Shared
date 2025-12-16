import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Kids AI App Typography
/// Einheitliche Schriften für alle Apps
class KidsTypography {
  KidsTypography._();

  // Font Family
  static String get fontFamily => GoogleFonts.nunito().fontFamily!;

  // Display Styles (große Überschriften)
  static TextStyle get displayLarge => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: KidsColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: KidsColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get displaySmall => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: KidsColors.textPrimary,
        height: 1.3,
      );

  // Headline Styles (Abschnittsüberschriften)
  static TextStyle get headlineLarge => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: KidsColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: KidsColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineSmall => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: KidsColors.textPrimary,
        height: 1.4,
      );

  // Title Styles (Card-Titel etc.)
  static TextStyle get titleLarge => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: KidsColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get titleMedium => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: KidsColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: KidsColors.textPrimary,
        height: 1.4,
      );

  // Body Styles (Fließtext)
  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: KidsColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: KidsColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: KidsColors.textSecondary,
        height: 1.5,
      );

  // Label Styles (Buttons, Chips etc.)
  static TextStyle get labelLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: KidsColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: KidsColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: KidsColors.textSecondary,
        height: 1.4,
      );

  // Special Styles für Kinder-Apps
  static TextStyle get gameTitle => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: KidsColors.textPrimary,
        letterSpacing: 1.2,
      );

  static TextStyle get score => GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: KidsColors.primary,
      );

  static TextStyle get emoji => const TextStyle(
        fontSize: 64,
        height: 1.0,
      );

  /// Skaliert Schriftgröße basierend auf Alter
  static TextStyle scaleForAge(TextStyle style, int age) {
    double multiplier = 1.0;
    if (age <= 5) multiplier = 1.3;
    else if (age <= 8) multiplier = 1.15;

    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * multiplier,
    );
  }

  /// Erstellt TextTheme für ThemeData
  static TextTheme get textTheme => TextTheme(
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
