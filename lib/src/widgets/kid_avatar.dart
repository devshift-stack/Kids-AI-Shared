import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Einheitlicher Avatar für Kids AI Apps
class KidAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final String? emoji;
  final KidAvatarSize size;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final int? age;

  const KidAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.emoji,
    this.size = KidAvatarSize.medium,
    this.backgroundColor,
    this.onTap,
    this.showBorder = false,
    this.age,
  });

  @override
  Widget build(BuildContext context) {
    final dimension = _getDimension();
    final bgColor = backgroundColor ??
        (age != null ? KidsColors.getAgeColor(age!) : KidsColors.primary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: showBorder
              ? Border.all(color: KidsColors.surface, width: 3)
              : null,
          boxShadow: KidsShadows.soft,
        ),
        child: ClipOval(
          child: _buildContent(dimension),
        ),
      ),
    );
  }

  Widget _buildContent(double dimension) {
    // Bild hat Priorität
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: dimension,
        height: dimension,
        errorBuilder: (_, __, ___) => _buildFallback(dimension),
      );
    }

    // Emoji als zweite Option
    if (emoji != null && emoji!.isNotEmpty) {
      return Center(
        child: Text(
          emoji!,
          style: TextStyle(fontSize: dimension * 0.5),
        ),
      );
    }

    // Name-Initialen als Fallback
    return _buildFallback(dimension);
  }

  Widget _buildFallback(double dimension) {
    final initials = _getInitials();
    return Center(
      child: Text(
        initials,
        style: KidsTypography.headlineMedium.copyWith(
          color: KidsColors.textLight,
          fontSize: dimension * 0.35,
        ),
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';

    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  double _getDimension() {
    switch (size) {
      case KidAvatarSize.small:
        return KidsSpacing.avatarSm;
      case KidAvatarSize.medium:
        return KidsSpacing.avatarMd;
      case KidAvatarSize.large:
        return KidsSpacing.avatarLg;
      case KidAvatarSize.extraLarge:
        return KidsSpacing.avatarXl;
      case KidAvatarSize.huge:
        return KidsSpacing.avatarXxl;
    }
  }
}

enum KidAvatarSize { small, medium, large, extraLarge, huge }

/// Avatar mit Rang-Anzeige (für Leaderboard)
class KidRankedAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final int rank;
  final KidAvatarSize size;

  const KidRankedAvatar({
    super.key,
    this.name,
    this.imageUrl,
    required this.rank,
    this.size = KidAvatarSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        KidAvatar(
          name: name,
          imageUrl: imageUrl,
          size: size,
          showBorder: rank <= 3,
          backgroundColor: _getRankColor(),
        ),
        if (rank <= 3)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: KidsGradients.getRankGradient(rank),
                shape: BoxShape.circle,
                border: Border.all(color: KidsColors.surface, width: 2),
              ),
              child: Text(
                _getRankEmoji(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return KidsColors.gold;
      case 2:
        return KidsColors.silver;
      case 3:
        return KidsColors.bronze;
      default:
        return KidsColors.primary;
    }
  }

  String _getRankEmoji() {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}
