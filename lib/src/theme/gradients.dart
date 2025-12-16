import 'package:flutter/material.dart';
import 'colors.dart';

/// Kids AI App Gradients
/// Einheitliche Farbverläufe für alle Apps
class KidsGradients {
  KidsGradients._();

  /// Primärer Gradient (Lila)
  static const LinearGradient primary = LinearGradient(
    colors: [KidsColors.primary, KidsColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sekundärer Gradient (Pink)
  static const LinearGradient secondary = LinearGradient(
    colors: [KidsColors.secondary, KidsColors.secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent Gradient (Cyan)
  static const LinearGradient accent = LinearGradient(
    colors: [KidsColors.accent, KidsColors.accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Haupt-Gradient für Charaktere/Maskottchen (Lila zu Pink)
  static const LinearGradient character = LinearGradient(
    colors: [KidsColors.primary, KidsColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Erfolgs-Gradient
  static const LinearGradient success = LinearGradient(
    colors: [KidsColors.success, KidsColors.successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Fehler-Gradient
  static const LinearGradient error = LinearGradient(
    colors: [KidsColors.error, KidsColors.errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warnung-Gradient
  static const LinearGradient warning = LinearGradient(
    colors: [KidsColors.warning, KidsColors.warningLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold-Gradient (für Rangliste #1)
  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Silber-Gradient (für Rangliste #2)
  static const LinearGradient silver = LinearGradient(
    colors: [Color(0xFFC0C0C0), Color(0xFFE8E8E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Bronze-Gradient (für Rangliste #3)
  static const LinearGradient bronze = LinearGradient(
    colors: [Color(0xFFCD7F32), Color(0xFFDDA15E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Regenbogen-Gradient (für Belohnungen/Erfolge)
  static const LinearGradient rainbow = LinearGradient(
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
      Color(0xFF4ECDC4),
      Color(0xFF6C63FF),
      Color(0xFFFF6584),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Hintergrund-Gradient (subtle)
  static const LinearGradient background = LinearGradient(
    colors: [KidsColors.background, KidsColors.surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Overlay-Gradient (für Bilder)
  static LinearGradient overlay = LinearGradient(
    colors: [
      Colors.black.withValues(alpha: 0.0),
      Colors.black.withValues(alpha: 0.6),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gibt Gradient basierend auf Spiel-Kategorie zurück
  static LinearGradient getGameGradient(String gameType) {
    final color = KidsColors.getGameColor(gameType);
    return LinearGradient(
      colors: [color, color.withValues(alpha: 0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Gibt Gradient basierend auf Ranglisten-Position zurück
  static LinearGradient getRankGradient(int rank) {
    if (rank == 1) return gold;
    if (rank == 2) return silver;
    if (rank == 3) return bronze;
    return primary;
  }
}
