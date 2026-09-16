import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Circular avatar that falls back to initials when no image resolves.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.avatarUrl,
    this.displayName = '',
    this.radius = 20,
    this.showOnline = false,
    this.isOnline = false,
  });

  final String? avatarUrl;
  final String displayName;
  final double radius;
  final bool showOnline;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(displayName);
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;

    final circle = SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _fallback(context, initials),
                errorWidget: (_, _, _) => _fallback(context, initials),
              ),
            )
          : _fallback(context, initials),
    );

    if (!showOnline) return circle;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: radius * 0.55,
            height: radius * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline
                  ? AppColors.onlineIndicator
                  : AppColors.offlineIndicator,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  Widget _fallback(BuildContext context, String initials) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer, // placeholder replaced below
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}