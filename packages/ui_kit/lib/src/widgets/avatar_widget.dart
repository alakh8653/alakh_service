import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 24,
    this.backgroundColor,
  });

  final String? imageUrl;
  final String? initials;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colors.primaryContainer;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) => _initialsWidget(colors, bgColor),
            errorWidget: (context, url, error) =>
                _initialsWidget(colors, bgColor),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: _initialsWidget(colors, bgColor),
    );
  }

  Widget _initialsWidget(ColorScheme colors, Color bgColor) {
    return Text(
      initials ?? '?',
      style: TextStyle(
        fontSize: radius * 0.7,
        fontWeight: FontWeight.w600,
        color: colors.onPrimaryContainer,
      ),
    );
  }
}
