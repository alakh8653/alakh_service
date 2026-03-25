import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// Generic button wrapper that manages a loading state.
///
/// [LoadingButton] accepts any [buttonBuilder] callback and invokes [onPressed]
/// while tracking async execution, swapping the button content for a spinner.
///
/// Example:
/// ```dart
/// LoadingButton(
///   onPressed: () async { await submitForm(); },
///   buttonBuilder: (context, onPressed, isLoading) => PrimaryButton(
///     onPressed: onPressed,
///     isLoading: isLoading,
///     child: const Text('Submit'),
///   ),
/// )
/// ```
class LoadingButton extends StatefulWidget {
  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.buttonBuilder,
  });

  /// Async or sync callback triggered on tap.
  final Future<void> Function()? onPressed;

  /// Builds the inner button widget.  Receives [isLoading] state and an
  /// [onPressed] that is `null` when loading or when the parent [onPressed]
  /// is `null`.
  final Widget Function(
    BuildContext context,
    VoidCallback? onPressed,
    bool isLoading,
  ) buttonBuilder;

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePressed() async {
    if (_isLoading || widget.onPressed == null) return;
    setState(() => _isLoading = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.buttonBuilder(
      context,
      widget.onPressed == null ? null : _handlePressed,
      _isLoading,
    );
  }
}

/// A standalone loading button that renders a full-width [ElevatedButton] with
/// a built-in loading state — useful when you don't need to customise style.
class SimpleLoadingButton extends StatefulWidget {
  const SimpleLoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isFullWidth = true,
  });

  final Future<void> Function()? onPressed;
  final Widget child;
  final bool isFullWidth;

  @override
  State<SimpleLoadingButton> createState() => _SimpleLoadingButtonState();
}

class _SimpleLoadingButtonState extends State<SimpleLoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePressed() async {
    if (_isLoading || widget.onPressed == null) return;
    setState(() => _isLoading = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: (widget.onPressed == null || _isLoading) ? null : _handlePressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: UiKitColors.primary,
        foregroundColor: UiKitColors.white,
        disabledBackgroundColor: UiKitColors.grey300,
        disabledForegroundColor: UiKitColors.grey500,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(UiKitColors.white),
              ),
            )
          : widget.child,
    );

    if (widget.isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
