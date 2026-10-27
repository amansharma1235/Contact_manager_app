import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Reusable avatar widget displaying contact initials or icon with vibrant color.
class ContactAvatar extends StatelessWidget {
  final String initials;
  final int colorIndex;
  final double radius;
  final double? fontSize;
  final bool showBadge;
  final IconData? badgeIcon;
  final Color? badgeColor;

  const ContactAvatar({
    super.key,
    required this.initials,
    this.colorIndex = 0,
    this.radius = 24,
    this.fontSize,
    this.showBadge = false,
    this.badgeIcon,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = AppTheme.getAvatarColor(colorIndex);
    final calculatedFontSize = fontSize ?? (radius * 0.75);

    final avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            baseColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: calculatedFontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );

    if (!showBadge) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: badgeColor ?? Colors.amber,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
            ),
            child: Icon(
              badgeIcon ?? Icons.star,
              size: radius * 0.45,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
