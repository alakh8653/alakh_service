/// Cached network image wrapper with placeholder, error widget, and loader.
library;

import 'package:flutter/material.dart';

// TODO: Add `cached_network_image` package to pubspec.yaml and replace the
// implementation below with CachedNetworkImage.

/// A network image widget that shows a shimmer placeholder while loading and
/// an error fallback when the image cannot be fetched.
///
/// ### Usage:
/// ```dart
/// AppImage(
///   url: 'https://example.com/photo.jpg',
///   width: 120,
///   height: 120,
///   fit: BoxFit.cover,
/// )
/// ```
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.heroTag,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final imageWidget = _buildImage(context);
    final clipped = borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: imageWidget)
        : imageWidget;

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: clipped);
    }
    return clipped;
  }

  Widget _buildImage(BuildContext context) {
    // TODO: Replace with CachedNetworkImage once package is added.
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _defaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultError(context),
    );
  }

  Widget _defaultPlaceholder() => SizedBox(
        width: width,
        height: height,
        child: Container(color: Colors.grey.shade200),
      );

  Widget _defaultError(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: Container(
          color: Colors.grey.shade100,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade400,
            size: 32,
          ),
        ),
      );
}
