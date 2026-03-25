import 'package:flutter/material.dart';

/// A row of animated dots that visualise progress through onboarding steps.
class StepIndicator extends StatelessWidget {
  /// Total number of steps.
  final int stepCount;

  /// Zero-based index of the currently active step.
  final int currentIndex;

  /// Colour of the active dot. Defaults to the theme's primary colour.
  final Color? activeColor;

  /// Colour of inactive dots. Defaults to grey[300].
  final Color? inactiveColor;

  /// Diameter of each dot.
  final double dotSize;

  /// Width of the active dot (elongated pill effect).
  final double activeDotWidth;

  const StepIndicator({
    super.key,
    required this.stepCount,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8.0,
    this.activeDotWidth = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? Theme.of(context).colorScheme.primary;
    final inactive = inactiveColor ?? Colors.grey[300]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(stepCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: dotSize,
          width: isActive ? activeDotWidth : dotSize,
          decoration: BoxDecoration(
            color: isActive ? active : inactive,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}
