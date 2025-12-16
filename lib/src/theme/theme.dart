import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';
import 'shadows.dart';
import 'gradients.dart';

// Re-export all theme components
export 'colors.dart';
export 'spacing.dart';
export 'typography.dart';
export 'shadows.dart';
export 'gradients.dart';

/// Kids AI App Theme
/// Einheitliches Theme für alle Apps
class KidsTheme {
  KidsTheme._();

  /// Light Theme (Standard)
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: KidsColors.primary,
        brightness: Brightness.light,
        primary: KidsColors.primary,
        secondary: KidsColors.secondary,
        surface: KidsColors.surface,
        error: KidsColors.error,
      ),
      scaffoldBackgroundColor: KidsColors.background,
      textTheme: KidsTypography.textTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
      bottomNavigationBarTheme: _bottomNavTheme,
      floatingActionButtonTheme: _fabTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme,
      chipTheme: _chipTheme,
      sliderTheme: _sliderTheme,
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      progressIndicatorTheme: _progressTheme,
    );
  }

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KidsColors.primary,
        foregroundColor: KidsColors.textLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: KidsSpacing.lg,
          vertical: KidsSpacing.md,
        ),
        minimumSize: Size(0, KidsSpacing.buttonMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
        ),
        textStyle: KidsTypography.labelLarge.copyWith(
          color: KidsColors.textLight,
        ),
      ),
    );
  }

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: KidsColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: KidsSpacing.lg,
          vertical: KidsSpacing.md,
        ),
        minimumSize: Size(0, KidsSpacing.buttonMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
        ),
        side: const BorderSide(color: KidsColors.primary, width: 2),
        textStyle: KidsTypography.labelLarge,
      ),
    );
  }

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: KidsColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: KidsSpacing.md,
          vertical: KidsSpacing.sm,
        ),
        textStyle: KidsTypography.labelLarge,
      ),
    );
  }

  // Card Theme
  static CardThemeData get _cardTheme {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusLg),
      ),
      color: KidsColors.surface,
      margin: EdgeInsets.zero,
    );
  }

  // AppBar Theme
  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: KidsTypography.headlineMedium,
      iconTheme: const IconThemeData(color: KidsColors.textPrimary),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: KidsColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KidsSpacing.md,
        vertical: KidsSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
        borderSide: const BorderSide(color: KidsColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
        borderSide: const BorderSide(color: KidsColors.error, width: 2),
      ),
      hintStyle: KidsTypography.bodyMedium.copyWith(
        color: KidsColors.textDisabled,
      ),
    );
  }

  // Bottom Navigation Theme
  static BottomNavigationBarThemeData get _bottomNavTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: KidsColors.surface,
      selectedItemColor: KidsColors.primary,
      unselectedItemColor: KidsColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: KidsTypography.labelSmall,
      unselectedLabelStyle: KidsTypography.labelSmall,
    );
  }

  // FAB Theme
  static FloatingActionButtonThemeData get _fabTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: KidsColors.primary,
      foregroundColor: KidsColors.textLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusLg),
      ),
    );
  }

  // Dialog Theme
  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      backgroundColor: KidsColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusLg),
      ),
      titleTextStyle: KidsTypography.headlineMedium,
      contentTextStyle: KidsTypography.bodyLarge,
    );
  }

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: KidsColors.textPrimary,
      contentTextStyle: KidsTypography.bodyMedium.copyWith(
        color: KidsColors.textLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  // Chip Theme
  static ChipThemeData get _chipTheme {
    return ChipThemeData(
      backgroundColor: KidsColors.surfaceVariant,
      selectedColor: KidsColors.primary,
      labelStyle: KidsTypography.labelMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: KidsSpacing.sm,
        vertical: KidsSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusRound),
      ),
    );
  }

  // Slider Theme
  static SliderThemeData get _sliderTheme {
    return SliderThemeData(
      activeTrackColor: KidsColors.primary,
      inactiveTrackColor: KidsColors.surfaceVariant,
      thumbColor: KidsColors.primary,
      overlayColor: KidsColors.primary.withValues(alpha: 0.2),
      trackHeight: 8,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
    );
  }

  // Switch Theme
  static SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return KidsColors.primary;
        }
        return KidsColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return KidsColors.primary.withValues(alpha: 0.5);
        }
        return KidsColors.surfaceVariant;
      }),
    );
  }

  // Checkbox Theme
  static CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return KidsColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(KidsColors.textLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KidsSpacing.radiusXs),
      ),
    );
  }

  // Progress Indicator Theme
  static ProgressIndicatorThemeData get _progressTheme {
    return const ProgressIndicatorThemeData(
      color: KidsColors.primary,
      linearTrackColor: KidsColors.surfaceVariant,
      circularTrackColor: KidsColors.surfaceVariant,
    );
  }
}
