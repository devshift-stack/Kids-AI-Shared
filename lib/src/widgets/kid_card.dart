import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Einheitliche Card für Kids AI Apps
class KidCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final bool elevated;

  const KidCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.width,
    this.height,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(KidsSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(KidsSpacing.radiusLg),
          child: Ink(
            decoration: BoxDecoration(
              color: gradient == null ? (color ?? KidsColors.surface) : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(KidsSpacing.radiusLg),
              boxShadow: elevated ? KidsShadows.card : null,
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(KidsSpacing.md),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Game-Kategorie Card
class KidGameCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String gameType;
  final VoidCallback? onTap;
  final int? progress; // 0-100

  const KidGameCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.gameType,
    this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final gameColor = KidsColors.getGameColor(gameType);

    return KidCard(
      onTap: onTap,
      elevated: true,
      gradient: KidsGradients.getGameGradient(gameType),
      padding: const EdgeInsets.all(KidsSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: KidsTypography.emoji,
          ),
          const SizedBox(height: KidsSpacing.sm),
          Text(
            title,
            style: KidsTypography.titleMedium.copyWith(
              color: KidsColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          if (progress != null) ...[
            const SizedBox(height: KidsSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(KidsSpacing.radiusRound),
              child: LinearProgressIndicator(
                value: progress! / 100,
                backgroundColor: KidsColors.textLight.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(KidsColors.textLight),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Statistik Card
class KidStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const KidStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? KidsColors.primary;

    return KidCard(
      elevated: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(KidsSpacing.sm),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
            ),
            child: Icon(icon, color: cardColor, size: KidsSpacing.iconMd),
          ),
          const SizedBox(height: KidsSpacing.md),
          Text(
            value,
            style: KidsTypography.headlineLarge.copyWith(color: cardColor),
          ),
          const SizedBox(height: KidsSpacing.xs),
          Text(
            title,
            style: KidsTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
