import 'package:flutter/material.dart';

/// Scales a [child] widget from [beginScale] to 1.0.
///
/// The animation runs once when the widget is first built. Use [delay] to
/// stagger multiple items for a "pop-in" effect.
class ScaleAnimation extends StatefulWidget {
  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    this.beginScale = 0.8,
    this.curve = Curves.easeOutBack,
    this.fade = true,
  });

  /// The widget to animate.
  final Widget child;

  /// Duration of the scale transition.
  final Duration duration;

  /// Delay before the animation starts.
  final Duration delay;

  /// Starting scale factor. Values < 1 create a grow-in effect.
  final double beginScale;

  final Curve curve;

  /// When `true` (default), the child also fades in alongside the scale.
  final bool fade;

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);

    _scale = Tween<double>(begin: widget.beginScale, end: 1.0).animate(curved);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = ScaleTransition(
      scale: _scale,
      child: widget.child,
    );

    if (widget.fade) {
      child = FadeTransition(opacity: _opacity, child: child);
    }

    return child;
  }
}
