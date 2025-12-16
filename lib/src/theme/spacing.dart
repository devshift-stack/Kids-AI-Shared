/// Kids AI App Spacing
/// Einheitliche Abstände für alle Apps
class KidsSpacing {
  KidsSpacing._();

  // Base Spacing (4px grid system)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusRound = 100.0;

  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // Button Heights
  static const double buttonSm = 36.0;
  static const double buttonMd = 48.0;
  static const double buttonLg = 56.0;
  static const double buttonXl = 64.0;

  // Card Sizes
  static const double cardSm = 120.0;
  static const double cardMd = 160.0;
  static const double cardLg = 200.0;

  // Avatar Sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;
  static const double avatarXxl = 128.0;

  /// Skaliert Spacing basierend auf Alter
  /// Jüngere Kinder = größere Touch-Targets
  static double scaleForAge(double baseValue, int age) {
    if (age <= 5) return baseValue * 1.3;
    if (age <= 8) return baseValue * 1.15;
    return baseValue;
  }
}
