import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// Overlays a semi-transparent barrier and a loading indicator on top of
/// [child] when [isLoading] is `true`.
///
/// All pointer events are absorbed while loading to prevent user interaction.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.barrierColor,
    this.progressColor,
  });

  /// When `true`, the overlay is shown and the child is non-interactive.
  final bool isLoading;

  /// The content displayed behind the overlay.
  final Widget child;

  /// Optional label shown below the spinner.
  final String? message;

  /// Background colour of the barrier. Defaults to 50 % black.
  final Color? barrierColor;

  /// Colour of the [CircularProgressIndicator]. Defaults to [UiKitColors.primary].
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLoading ? 1.0 : 0.0,
                child: ColoredBox(
                  color: barrierColor ?? Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor ?? UiKitColors.primary,
                          ),
                        ),
                        if (message != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            message!,
                            style: const TextStyle(
                              color: UiKitColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
