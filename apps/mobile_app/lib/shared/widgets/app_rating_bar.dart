/// Star rating display and input widget.
library;

import 'package:flutter/material.dart';

/// Displays a row of star icons for rating input or display.
///
/// Set [onChanged] to `null` for a read-only rating display.
///
/// ### Usage:
/// ```dart
/// AppRatingBar(
///   rating: 4.5,
///   onChanged: (value) => setState(() => _rating = value),
/// )
/// ```
class AppRatingBar extends StatelessWidget {
  const AppRatingBar({
    super.key,
    required this.rating,
    this.onChanged,
    this.maxRating = 5,
    this.starSize = 28,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = true,
    this.spacing = 4,
  });

  /// The current rating value (0 – [maxRating]).
  final double rating;

  /// Callback when the user selects a rating. `null` = read-only.
  final ValueChanged<double>? onChanged;

  final int maxRating;

  /// Size of each star icon.
  final double starSize;

  final Color? activeColor;
  final Color? inactiveColor;

  /// When `true`, tapping the left half of a star gives a half-star rating.
  final bool allowHalfRating;

  /// Horizontal spacing between stars.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filled = activeColor ?? const Color(0xFFFFC107);
    final empty = inactiveColor ??
        theme.colorScheme.onSurface.withValues(alpha: 0.2);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        final isFullStar = rating >= starValue;
        final isHalfStar =
            allowHalfRating && rating >= starValue - 0.5 && rating < starValue;

        Widget star = Icon(
          isFullStar
              ? Icons.star_rounded
              : isHalfStar
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: starSize,
          color: (isFullStar || isHalfStar) ? filled : empty,
        );

        if (onChanged != null) {
          star = GestureDetector(
            onTapUp: (details) {
              if (allowHalfRating) {
                // Left half → half star, right half → full star
                final isLeft = details.localPosition.dx < starSize / 2;
                onChanged!(isLeft ? starValue - 0.5 : starValue.toDouble());
              } else {
                onChanged!(starValue.toDouble());
              }
            },
            child: star,
          );
        }

        return Padding(
          padding: EdgeInsets.only(right: index < maxRating - 1 ? spacing : 0),
          child: star,
        );
      }),
    );
  }
}
