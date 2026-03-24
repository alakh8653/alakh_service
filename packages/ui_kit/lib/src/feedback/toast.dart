import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// Overlay-based toast notification.
///
/// Toasts appear at the bottom of the screen and automatically dismiss after
/// [duration]. They do not require a [Scaffold].
abstract class UiKitToast {
  /// Shows a toast with a custom [backgroundColor].
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = UiKitColors.grey800,
    Color textColor = UiKitColors.white,
    IconData? icon,
    ToastPosition position = ToastPosition.bottom,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        position: position,
        onDismiss: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }

  /// Shows a success (green) toast.
  static void showSuccess(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 2)}) {
    show(
      context,
      message,
      duration: duration,
      backgroundColor: UiKitColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Shows an error (red) toast.
  static void showError(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    show(
      context,
      message,
      duration: duration,
      backgroundColor: UiKitColors.error,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Shows an info (blue) toast.
  static void showInfo(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 2)}) {
    show(
      context,
      message,
      duration: duration,
      backgroundColor: UiKitColors.info,
      icon: Icons.info_outline_rounded,
    );
  }
}

/// Vertical position of the toast on screen.
enum ToastPosition { top, center, bottom }

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.onDismiss,
    required this.duration,
    required this.position,
    this.icon,
  });

  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final ToastPosition position;
  final VoidCallback onDismiss;
  final Duration duration;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    _timer = Timer(widget.duration, () async {
      await _controller.reverse();
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Alignment get _alignment {
    switch (widget.position) {
      case ToastPosition.top:
        return const Alignment(0, -0.85);
      case ToastPosition.center:
        return Alignment.center;
      case ToastPosition.bottom:
        return const Alignment(0, 0.85);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: _alignment,
          child: FadeTransition(
            opacity: _opacity,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.textColor, size: 16),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
