import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/gradients.dart';

/// Card-Varianten
enum KidCardVariant {
  elevated,
  outlined,
  filled,
  gradient,
}

/// Kids AI Card Widget
/// Kindgerechte Karte mit verschiedenen Stilen
class KidCard extends StatefulWidget {
  const KidCard({
    super.key,
    required this.child,
    this.variant = KidCardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.gradient,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation = 1,
    this.isSelected = false,
    this.isDisabled = false,
    this.animateOnTap = true,
  });

  /// Inhalt der Karte
  final Widget child;

  /// Variante (elevated, outlined, filled, gradient)
  final KidCardVariant variant;

  /// Padding innerhalb der Karte
  final EdgeInsets? padding;

  /// Margin außerhalb der Karte
  final EdgeInsets? margin;

  /// Tap-Callback
  final VoidCallback? onTap;

  /// LongPress-Callback
  final VoidCallback? onLongPress;

  /// Custom Gradient (überschreibt Standard)
  final Gradient? gradient;

  /// Custom Hintergrundfarbe
  final Color? backgroundColor;

  /// Custom Randfarbe
  final Color? borderColor;

  /// Custom BorderRadius
  final BorderRadius? borderRadius;

  /// Schattenstärke (0-3)
  final int elevation;

  /// Ausgewählt-Status
  final bool isSelected;

  /// Deaktiviert
  final bool isDisabled;

  /// Animation beim Tippen
  final bool animateOnTap;

  @override
  State<KidCard> createState() => _KidCardState();
}

class _KidCardState extends State<KidCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  EdgeInsets get _padding =>
      widget.padding ?? KidsSpacing.cardPadding;

  BorderRadius get _borderRadius =>
      widget.borderRadius ?? KidsSpacing.borderRadiusLg;

  Color get _backgroundColor {
    if (widget.isDisabled) return KidsColors.surfaceVariant;
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.variant) {
      case KidCardVariant.elevated:
      case KidCardVariant.outlined:
        return KidsColors.surface;
      case KidCardVariant.filled:
        return KidsColors.surfaceVariant;
      case KidCardVariant.gradient:
        return Colors.transparent;
    }
  }

  Gradient? get _gradient {
    if (widget.variant == KidCardVariant.gradient) {
      return widget.gradient ?? KidsGradients.primary;
    }
    return null;
  }

  Border? get _border {
    if (widget.isSelected) {
      return Border.all(
        color: KidsColors.primary,
        width: 2,
      );
    }

    if (widget.variant == KidCardVariant.outlined) {
      return Border.all(
        color: widget.borderColor ?? KidsColors.border,
        width: 1,
      );
    }

    return null;
  }

  List<BoxShadow> get _shadow {
    if (widget.variant == KidCardVariant.outlined ||
        widget.variant == KidCardVariant.filled) {
      return KidsShadows.none;
    }

    switch (widget.elevation) {
      case 0:
        return KidsShadows.none;
      case 1:
        return KidsShadows.sm;
      case 2:
        return KidsShadows.md;
      case 3:
        return KidsShadows.lg;
      default:
        return KidsShadows.md;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.animateOnTap &&
        widget.onTap != null &&
        !widget.isDisabled) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: _gradient == null ? _backgroundColor : null,
        gradient: _gradient,
        borderRadius: _borderRadius,
        border: _border,
        boxShadow: _shadow,
      ),
      child: ClipRRect(
        borderRadius: _borderRadius,
        child: Padding(
          padding: _padding,
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      card = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.isDisabled ? null : widget.onTap,
        onLongPress: widget.isDisabled ? null : widget.onLongPress,
        child: widget.animateOnTap
            ? AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: card,
              )
            : card,
      );
    }

    return card;
  }
}

/// Game Card - Speziell für Spielauswahl
class KidGameCard extends StatelessWidget {
  const KidGameCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.gradient,
    this.isLocked = false,
    this.progress,
    this.stars = 0,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;
  final Gradient? gradient;
  final bool isLocked;
  final double? progress;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return KidCard(
      variant: KidCardVariant.gradient,
      gradient: isLocked
          ? const LinearGradient(
              colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
            )
          : gradient ?? KidsGradients.primary,
      onTap: isLocked ? null : onTap,
      isDisabled: isLocked,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: KidsSpacing.gameCardSize,
        height: KidsSpacing.gameCardSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stars
            if (stars > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: index < stars
                        ? KidsColors.star
                        : Colors.white.withValues(alpha: 0.5),
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 8),
            ],

            // Icon oder Lock
            Icon(
              isLocked ? Icons.lock : icon,
              size: 48,
              color: Colors.white,
            ),

            const SizedBox(height: 12),

            // Titel
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Progress
            if (progress != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress!,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Statistic Card - Für Eltern-Dashboard
class KidStatCard extends StatelessWidget {
  const KidStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.trend,
    this.trendValue,
    this.backgroundColor,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final bool? trend; // true = up, false = down, null = no trend
  final String? trendValue;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return KidCard(
      backgroundColor: backgroundColor ?? KidsColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: KidsColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: KidsColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: KidsColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: KidsColors.textPrimary,
            ),
          ),

          // Trend
          if (trend != null && trendValue != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  trend! ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: trend! ? KidsColors.success : KidsColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  trendValue!,
                  style: TextStyle(
                    fontSize: 12,
                    color: trend! ? KidsColors.success : KidsColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: KidsColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
