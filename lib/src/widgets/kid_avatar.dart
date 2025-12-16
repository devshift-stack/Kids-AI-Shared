import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/gradients.dart';

/// Avatar-Größen
enum KidAvatarSize {
  xs,
  sm,
  md,
  lg,
  xl,
}

/// Kids AI Avatar Widget
/// Kindgerechter Avatar mit verschiedenen Varianten
class KidAvatar extends StatelessWidget {
  const KidAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.size = KidAvatarSize.md,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
    this.showBadge = false,
    this.badgeColor,
    this.badgeIcon,
    this.isOnline,
  });

  /// Bild-URL
  final String? imageUrl;

  /// Name für Initialen-Fallback
  final String? name;

  /// Icon als Fallback
  final IconData? icon;

  /// Größe
  final KidAvatarSize size;

  /// Hintergrundfarbe (falls kein Bild)
  final Color? backgroundColor;

  /// Randfarbe
  final Color? borderColor;

  /// Randbreite
  final double borderWidth;

  /// Tap-Callback
  final VoidCallback? onTap;

  /// Badge anzeigen
  final bool showBadge;

  /// Badge-Farbe
  final Color? badgeColor;

  /// Badge-Icon
  final IconData? badgeIcon;

  /// Online-Status
  final bool? isOnline;

  double get _size {
    switch (size) {
      case KidAvatarSize.xs:
        return KidsSpacing.avatarXs;
      case KidAvatarSize.sm:
        return KidsSpacing.avatarSm;
      case KidAvatarSize.md:
        return KidsSpacing.avatarMd;
      case KidAvatarSize.lg:
        return KidsSpacing.avatarLg;
      case KidAvatarSize.xl:
        return KidsSpacing.avatarXl;
    }
  }

  double get _fontSize {
    switch (size) {
      case KidAvatarSize.xs:
        return 12;
      case KidAvatarSize.sm:
        return 14;
      case KidAvatarSize.md:
        return 20;
      case KidAvatarSize.lg:
        return 28;
      case KidAvatarSize.xl:
        return 40;
    }
  }

  double get _iconSize {
    switch (size) {
      case KidAvatarSize.xs:
        return 16;
      case KidAvatarSize.sm:
        return 20;
      case KidAvatarSize.md:
        return 28;
      case KidAvatarSize.lg:
        return 40;
      case KidAvatarSize.xl:
        return 56;
    }
  }

  double get _badgeSize {
    switch (size) {
      case KidAvatarSize.xs:
        return 10;
      case KidAvatarSize.sm:
        return 12;
      case KidAvatarSize.md:
        return 16;
      case KidAvatarSize.lg:
        return 20;
      case KidAvatarSize.xl:
        return 28;
    }
  }

  String get _initials {
    if (name == null || name!.isEmpty) return '?';

    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  Color get _backgroundColor {
    if (backgroundColor != null) return backgroundColor!;
    if (name != null && name!.isNotEmpty) {
      return KidsColors.avatarColorAt(name!.hashCode);
    }
    return KidsColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: _backgroundColor,
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? KidsColors.surface,
                width: borderWidth,
              )
            : null,
        boxShadow: KidsShadows.sm,
      ),
      child: ClipOval(
        child: _buildContent(),
      ),
    );

    // Badge oder Online-Status
    if (showBadge || isOnline != null) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildBadge(),
          ),
        ],
      );
    }

    // Tap-Handler
    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildContent() {
    // Bild
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    // Icon
    if (icon != null) {
      return Center(
        child: Icon(
          icon,
          size: _iconSize,
          color: KidsColors.textOnPrimary,
        ),
      );
    }

    // Initialen
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          color: KidsColors.textOnPrimary,
          fontSize: _fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBadge() {
    // Online-Status
    if (isOnline != null) {
      return Container(
        width: _badgeSize,
        height: _badgeSize,
        decoration: BoxDecoration(
          color: isOnline! ? KidsColors.success : KidsColors.textMuted,
          shape: BoxShape.circle,
          border: Border.all(
            color: KidsColors.surface,
            width: 2,
          ),
        ),
      );
    }

    // Custom Badge
    return Container(
      width: _badgeSize,
      height: _badgeSize,
      decoration: BoxDecoration(
        color: badgeColor ?? KidsColors.accent,
        shape: BoxShape.circle,
        border: Border.all(
          color: KidsColors.surface,
          width: 2,
        ),
      ),
      child: badgeIcon != null
          ? Icon(
              badgeIcon,
              size: _badgeSize * 0.6,
              color: KidsColors.textOnPrimary,
            )
          : null,
    );
  }
}

/// Avatar-Gruppe (gestapelt)
class KidAvatarGroup extends StatelessWidget {
  const KidAvatarGroup({
    super.key,
    required this.avatars,
    this.size = KidAvatarSize.sm,
    this.maxVisible = 3,
    this.onTap,
  });

  /// Liste von Avatar-Daten
  final List<KidAvatarData> avatars;

  /// Größe aller Avatare
  final KidAvatarSize size;

  /// Maximale sichtbare Avatare
  final int maxVisible;

  /// Tap auf gesamte Gruppe
  final VoidCallback? onTap;

  double get _size {
    switch (size) {
      case KidAvatarSize.xs:
        return KidsSpacing.avatarXs;
      case KidAvatarSize.sm:
        return KidsSpacing.avatarSm;
      case KidAvatarSize.md:
        return KidsSpacing.avatarMd;
      case KidAvatarSize.lg:
        return KidsSpacing.avatarLg;
      case KidAvatarSize.xl:
        return KidsSpacing.avatarXl;
    }
  }

  double get _overlap => _size * 0.3;

  @override
  Widget build(BuildContext context) {
    final visibleAvatars = avatars.take(maxVisible).toList();
    final remaining = avatars.length - maxVisible;

    Widget group = SizedBox(
      height: _size,
      width: _size + (visibleAvatars.length - 1) * (_size - _overlap) +
          (remaining > 0 ? (_size - _overlap) : 0),
      child: Stack(
        children: [
          // Avatare
          for (int i = 0; i < visibleAvatars.length; i++)
            Positioned(
              left: i * (_size - _overlap),
              child: KidAvatar(
                imageUrl: visibleAvatars[i].imageUrl,
                name: visibleAvatars[i].name,
                icon: visibleAvatars[i].icon,
                size: size,
                borderWidth: 2,
                borderColor: KidsColors.surface,
              ),
            ),

          // Überzählige Anzeige
          if (remaining > 0)
            Positioned(
              left: visibleAvatars.length * (_size - _overlap),
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  color: KidsColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: KidsColors.surface,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      fontSize: _size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: KidsColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      group = GestureDetector(
        onTap: onTap,
        child: group,
      );
    }

    return group;
  }
}

/// Daten für Avatar-Gruppe
class KidAvatarData {
  const KidAvatarData({
    this.imageUrl,
    this.name,
    this.icon,
  });

  final String? imageUrl;
  final String? name;
  final IconData? icon;
}

/// Lianko Charakter-Avatar (animiert)
class LiankoAvatar extends StatefulWidget {
  const LiankoAvatar({
    super.key,
    this.size = 120,
    this.isAnimated = true,
    this.emotion = LiankoEmotion.happy,
    this.onTap,
  });

  final double size;
  final bool isAnimated;
  final LiankoEmotion emotion;
  final VoidCallback? onTap;

  @override
  State<LiankoAvatar> createState() => _LiankoAvatarState();
}

class _LiankoAvatarState extends State<LiankoAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: KidsGradients.primary,
          shape: BoxShape.circle,
          boxShadow: KidsShadows.lg,
        ),
        child: Center(
          child: Text(
            _getEmotionEmoji(),
            style: TextStyle(fontSize: widget.size * 0.5),
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      avatar = GestureDetector(
        onTap: widget.onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  String _getEmotionEmoji() {
    switch (widget.emotion) {
      case LiankoEmotion.happy:
        return '😊';
      case LiankoEmotion.excited:
        return '🤩';
      case LiankoEmotion.thinking:
        return '🤔';
      case LiankoEmotion.surprised:
        return '😮';
      case LiankoEmotion.proud:
        return '😎';
      case LiankoEmotion.encouraging:
        return '💪';
      case LiankoEmotion.sleeping:
        return '😴';
    }
  }
}

/// Lianko Emotionen
enum LiankoEmotion {
  happy,
  excited,
  thinking,
  surprised,
  proud,
  encouraging,
  sleeping,
}
