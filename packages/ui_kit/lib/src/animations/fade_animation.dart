import 'package:flutter/material.dart';

/// Fades a [child] widget in, optionally after a [delay].
///
/// The animation runs once when the widget is first built. Use [delay] to
/// stagger multiple widgets in a list.
class FadeAnimation extends StatefulWidget {
  const FadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.begin = 0.0,
    this.curve = Curves.easeOut,
  });

  /// The widget to animate.
  final Widget child;

  /// Duration of the fade transition.
  final Duration duration;

  /// Delay before the animation starts.
  final Duration delay;

  /// Starting opacity. Should be in the range [0.0, 1.0].
  final double begin;

  final Curve curve;

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = Tween<double>(begin: widget.begin, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
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
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}
