import 'package:flutter/material.dart';

/// Slides a [child] widget from [beginOffset] to its natural position.
///
/// The animation runs once when the widget is first built. Use [delay] to
/// stagger multiple items.
class SlideAnimation extends StatefulWidget {
  const SlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0.0, 0.2),
    this.curve = Curves.easeOut,
    this.fade = true,
  });

  /// The widget to animate.
  final Widget child;

  /// Duration of the slide transition.
  final Duration duration;

  /// Delay before the animation starts.
  final Duration delay;

  /// Starting fractional offset. `Offset(0, 0.2)` slides up from 20 % below.
  final Offset beginOffset;

  final Curve curve;

  /// When `true` (default), the child also fades in alongside the slide.
  final bool fade;

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);

    _slide = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(curved);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

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
    Widget child = SlideTransition(
      position: _slide,
      child: widget.child,
    );

    if (widget.fade) {
      child = FadeTransition(opacity: _opacity, child: child);
    }

    return child;
  }
}
