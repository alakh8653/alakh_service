/// Loading indicators: spinner, shimmer skeleton, and full-screen overlay.
library;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Spinner
// ---------------------------------------------------------------------------

/// A simple centred [CircularProgressIndicator] with optional [size].
class AppSpinner extends StatelessWidget {
  const AppSpinner({super.key, this.size = 36, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox.square(
          dimension: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// Shimmer skeleton
// ---------------------------------------------------------------------------

/// Animates a shimmer effect over its [child] to indicate loading.
///
/// ### Usage:
/// ```dart
/// AppShimmer(
///   child: Column(children: [
///     AppSkeletonBox(width: double.infinity, height: 120),
///     const SizedBox(height: 8),
///     AppSkeletonBox(width: 200, height: 16),
///   ]),
/// )
/// ```
class AppShimmer extends StatefulWidget {
  const AppShimmer({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value + 1, 0),
            colors: const [
              Color(0xFFE0E0E0),
              Color(0xFFF5F5F5),
              Color(0xFFE0E0E0),
            ],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

/// A grey rectangular skeleton placeholder used with [AppShimmer].
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      );
}

// ---------------------------------------------------------------------------
// Full-screen loading overlay
// ---------------------------------------------------------------------------

/// A full-screen translucent overlay with a centred spinner and optional
/// [message].
///
/// Typically used with a [Stack] at the root of a screen.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key, this.message});

  final String? message;

  /// Shows the overlay on top of the current route.
  static Future<void> show(BuildContext context, {String? message}) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (_) => AppLoadingOverlay(message: message),
      );

  /// Dismisses the overlay (pops the dialog route).
  static void hide(BuildContext context) => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppSpinner(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(message!),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}
