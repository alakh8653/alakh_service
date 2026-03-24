import 'package:flutter/material.dart';

/// A reusable header widget for authentication screens with a logo, title and subtitle.
class AuthHeader extends StatelessWidget {
  /// Path to the logo asset.
  final String? logoAsset;

  /// Main title text.
  final String title;

  /// Subtitle/description text.
  final String? subtitle;

  const AuthHeader({
    super.key,
    this.logoAsset,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (logoAsset != null) ...[
          Image.asset(
            logoAsset!,
            height: 80,
            // TODO: Replace with your actual logo asset path.
            errorBuilder: (_, __, ___) => Icon(
              Icons.school,
              size: 80,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
