import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// Displays the content for a single [OnboardingStep]: image, title, and
/// description.
class OnboardingStepWidget extends StatelessWidget {
  /// The step data to render.
  final OnboardingStep step;

  const OnboardingStepWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          SizedBox(
            height: size.height * 0.35,
            child: Image.asset(
              step.imageAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_outlined,
                size: 120,
                color: theme.colorScheme.primary.withOpacity(0.4),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
