import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/gradients.dart';

/// Button-Varianten
enum KidButtonVariant {
  primary,
  secondary,
  accent,
  success,
  outline,
  ghost,
}

/// Button-Größen
enum KidButtonSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Kids AI Button Widget
/// Kindgerechter Button mit verschiedenen Varianten und Animationen
class KidButton extends StatefulWidget {
  const KidButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = KidButtonVariant.primary,
    this.size = KidButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.hapticFeedback = true,
  });

  /// Button-Callback
  final VoidCallback? onPressed;

  /// Button-Text
  final String label;

  /// Optionales Icon (links vom Text)
  final IconData? icon;

  /// Farbvariante
  final KidButtonVariant variant;

  /// Größe
  final KidButtonSize size;

  /// Zeigt Ladeindikator
  final bool isLoading;

  /// Deaktiviert den Button
  final bool isDisabled;

  /// Volle Breite
  final bool fullWidth;

  /// Haptisches Feedback beim Drücken
  final bool hapticFeedback;

  @override
  State<KidButton> createState() => _KidButtonState();
}

class _KidButtonState extends State<KidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  double get _height {
    switch (widget.size) {
      case KidButtonSize.small:
        return KidsSpacing.buttonHeightSm;
      case KidButtonSize.medium:
        return KidsSpacing.buttonHeightMd;
      case KidButtonSize.large:
        return KidsSpacing.buttonHeightLg;
      case KidButtonSize.extraLarge:
        return KidsSpacing.buttonHeightXl;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case KidButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case KidButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case KidButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      case KidButtonSize.extraLarge:
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case KidButtonSize.small:
        return KidsTypography.labelSmall;
      case KidButtonSize.medium:
        return KidsTypography.labelMedium;
      case KidButtonSize.large:
        return KidsTypography.labelLarge;
      case KidButtonSize.extraLarge:
        return KidsTypography.labelLarge.copyWith(fontSize: 18);
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case KidButtonSize.small:
        return KidsSpacing.iconXs;
      case KidButtonSize.medium:
        return KidsSpacing.iconSm;
      case KidButtonSize.large:
        return KidsSpacing.iconMd;
      case KidButtonSize.extraLarge:
        return KidsSpacing.iconLg;
    }
  }

  Color get _backgroundColor {
    if (widget.isDisabled) return KidsColors.textMuted;

    switch (widget.variant) {
      case KidButtonVariant.primary:
        return KidsColors.primary;
      case KidButtonVariant.secondary:
        return KidsColors.secondary;
      case KidButtonVariant.accent:
        return KidsColors.accent;
      case KidButtonVariant.success:
        return KidsColors.success;
      case KidButtonVariant.outline:
      case KidButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    if (widget.isDisabled) return KidsColors.textOnPrimary;

    switch (widget.variant) {
      case KidButtonVariant.primary:
      case KidButtonVariant.secondary:
      case KidButtonVariant.success:
        return KidsColors.textOnPrimary;
      case KidButtonVariant.accent:
        return KidsColors.textPrimary;
      case KidButtonVariant.outline:
        return KidsColors.primary;
      case KidButtonVariant.ghost:
        return KidsColors.textPrimary;
    }
  }

  Border? get _border {
    if (widget.variant == KidButtonVariant.outline) {
      return Border.all(
        color: widget.isDisabled ? KidsColors.textMuted : KidsColors.primary,
        width: 2,
      );
    }
    return null;
  }

  List<BoxShadow> get _shadow {
    if (widget.isDisabled ||
        widget.variant == KidButtonVariant.ghost ||
        widget.variant == KidButtonVariant.outline) {
      return KidsShadows.none;
    }

    if (_isPressed) {
      return KidsShadows.sm;
    }

    switch (widget.variant) {
      case KidButtonVariant.primary:
        return KidsShadows.primary;
      case KidButtonVariant.secondary:
      case KidButtonVariant.accent:
      case KidButtonVariant.success:
        return KidsShadows.md;
      default:
        return KidsShadows.none;
    }
  }

  Gradient? get _gradient {
    if (widget.isDisabled) return null;

    switch (widget.variant) {
      case KidButtonVariant.primary:
        return KidsGradients.primary;
      case KidButtonVariant.secondary:
        return KidsGradients.secondary;
      case KidButtonVariant.accent:
        return KidsGradients.accent;
      case KidButtonVariant.success:
        return KidsGradients.success;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _height,
          padding: _padding,
          decoration: BoxDecoration(
            color: _gradient == null ? _backgroundColor : null,
            gradient: _gradient,
            borderRadius: KidsSpacing.borderRadiusRound,
            border: _border,
            boxShadow: _shadow,
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: _iconSize,
                  height: _iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: _iconSize,
                  color: _textColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: _textStyle.copyWith(color: _textColor),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// Icon-Only Button (rund)
class KidIconButton extends StatefulWidget {
  const KidIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.variant = KidButtonVariant.primary,
    this.size = KidButtonSize.medium,
    this.isDisabled = false,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final KidButtonVariant variant;
  final KidButtonSize size;
  final bool isDisabled;
  final String? tooltip;

  @override
  State<KidIconButton> createState() => _KidIconButtonState();
}

class _KidIconButtonState extends State<KidIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _size {
    switch (widget.size) {
      case KidButtonSize.small:
        return 36;
      case KidButtonSize.medium:
        return 48;
      case KidButtonSize.large:
        return 56;
      case KidButtonSize.extraLarge:
        return 64;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case KidButtonSize.small:
        return KidsSpacing.iconXs;
      case KidButtonSize.medium:
        return KidsSpacing.iconSm;
      case KidButtonSize.large:
        return KidsSpacing.iconMd;
      case KidButtonSize.extraLarge:
        return KidsSpacing.iconLg;
    }
  }

  Color get _backgroundColor {
    if (widget.isDisabled) return KidsColors.textMuted;

    switch (widget.variant) {
      case KidButtonVariant.primary:
        return KidsColors.primary;
      case KidButtonVariant.secondary:
        return KidsColors.secondary;
      case KidButtonVariant.accent:
        return KidsColors.accent;
      case KidButtonVariant.success:
        return KidsColors.success;
      case KidButtonVariant.outline:
      case KidButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _iconColor {
    if (widget.isDisabled) return KidsColors.textOnPrimary;

    switch (widget.variant) {
      case KidButtonVariant.primary:
      case KidButtonVariant.secondary:
      case KidButtonVariant.success:
        return KidsColors.textOnPrimary;
      case KidButtonVariant.accent:
        return KidsColors.textPrimary;
      case KidButtonVariant.outline:
        return KidsColors.primary;
      case KidButtonVariant.ghost:
        return KidsColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: _backgroundColor,
            shape: BoxShape.circle,
            border: widget.variant == KidButtonVariant.outline
                ? Border.all(color: KidsColors.primary, width: 2)
                : null,
            boxShadow: widget.variant != KidButtonVariant.ghost &&
                    widget.variant != KidButtonVariant.outline &&
                    !widget.isDisabled
                ? KidsShadows.sm
                : null,
          ),
          child: Icon(
            widget.icon,
            size: _iconSize,
            color: _iconColor,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
