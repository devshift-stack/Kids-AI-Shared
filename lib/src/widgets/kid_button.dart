import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Einheitlicher Button für Kids AI Apps
class KidButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? emoji;
  final KidButtonStyle style;
  final KidButtonSize size;
  final bool isLoading;
  final Color? color;

  const KidButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.emoji,
    this.style = KidButtonStyle.filled,
    this.size = KidButtonSize.medium,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? KidsColors.primary;
    final height = _getHeight();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
          child: Ink(
            decoration: _getDecoration(buttonColor),
            child: Container(
              padding: padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _getForegroundColor(buttonColor),
                      ),
                    ),
                    const SizedBox(width: KidsSpacing.sm),
                  ],
                  if (emoji != null && !isLoading) ...[
                    Text(emoji!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: KidsSpacing.sm),
                  ],
                  if (icon != null && !isLoading) ...[
                    Icon(
                      icon,
                      color: _getForegroundColor(buttonColor),
                      size: _getIconSize(),
                    ),
                    const SizedBox(width: KidsSpacing.sm),
                  ],
                  Text(
                    label,
                    style: textStyle.copyWith(
                      color: _getForegroundColor(buttonColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(Color buttonColor) {
    switch (style) {
      case KidButtonStyle.filled:
        return BoxDecoration(
          color: onPressed == null ? buttonColor.withValues(alpha: 0.5) : buttonColor,
          borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
          boxShadow: onPressed != null ? KidsShadows.button : null,
        );
      case KidButtonStyle.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
          border: Border.all(
            color: onPressed == null ? buttonColor.withValues(alpha: 0.5) : buttonColor,
            width: 2,
          ),
        );
      case KidButtonStyle.soft:
        return BoxDecoration(
          color: buttonColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
        );
      case KidButtonStyle.gradient:
        return BoxDecoration(
          gradient: onPressed == null ? null : KidsGradients.primary,
          color: onPressed == null ? buttonColor.withValues(alpha: 0.5) : null,
          borderRadius: BorderRadius.circular(KidsSpacing.radiusMd),
          boxShadow: onPressed != null ? KidsShadows.button : null,
        );
    }
  }

  Color _getForegroundColor(Color buttonColor) {
    switch (style) {
      case KidButtonStyle.filled:
      case KidButtonStyle.gradient:
        return KidsColors.textLight;
      case KidButtonStyle.outlined:
      case KidButtonStyle.soft:
        return buttonColor;
    }
  }

  double _getHeight() {
    switch (size) {
      case KidButtonSize.small:
        return KidsSpacing.buttonSm;
      case KidButtonSize.medium:
        return KidsSpacing.buttonMd;
      case KidButtonSize.large:
        return KidsSpacing.buttonLg;
      case KidButtonSize.extraLarge:
        return KidsSpacing.buttonXl;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case KidButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: KidsSpacing.md);
      case KidButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: KidsSpacing.lg);
      case KidButtonSize.large:
      case KidButtonSize.extraLarge:
        return const EdgeInsets.symmetric(horizontal: KidsSpacing.xl);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case KidButtonSize.small:
        return KidsTypography.labelSmall;
      case KidButtonSize.medium:
        return KidsTypography.labelMedium;
      case KidButtonSize.large:
      case KidButtonSize.extraLarge:
        return KidsTypography.labelLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case KidButtonSize.small:
        return KidsSpacing.iconSm;
      case KidButtonSize.medium:
        return KidsSpacing.iconMd;
      case KidButtonSize.large:
      case KidButtonSize.extraLarge:
        return KidsSpacing.iconLg;
    }
  }
}

enum KidButtonStyle { filled, outlined, soft, gradient }
enum KidButtonSize { small, medium, large, extraLarge }
