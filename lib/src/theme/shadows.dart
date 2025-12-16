import 'package:flutter/material.dart';
import 'colors.dart';

/// Kids AI App Shadows
/// Einheitliche Schatten für alle Apps
class KidsShadows {
  KidsShadows._();

  /// Weicher Schatten für erhöhte Elemente
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: KidsColors.primary.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  /// Standard Card-Schatten
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Schatten für Buttons
  static List<BoxShadow> get button => [
        BoxShadow(
          color: KidsColors.primary.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  /// Schatten für schwebende Elemente (FAB, Modals)
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  /// Schatten für gedrückte Buttons
  static List<BoxShadow> get pressed => [
        BoxShadow(
          color: KidsColors.primary.withValues(alpha: 0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Innerer Schatten für Input-Felder
  static List<BoxShadow> get inset => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];

  /// Glow-Effekt für aktive/fokussierte Elemente
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ];

  /// Kein Schatten
  static List<BoxShadow> get none => [];
}
