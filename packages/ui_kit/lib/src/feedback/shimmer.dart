import 'package:flutter/material.dart';

import '../theme/ui_kit_colors.dart';

/// An animated shimmer placeholder box.
///
/// Use [ShimmerBox] for individual placeholders (e.g. image/text skeleton)
/// and [ShimmerList] for a column of repeated item skeletons.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  /// Width of the shimmer box. Use `double.infinity` to fill the parent.
  final double width;

  /// Height of the shimmer box.
  final double height;

  /// Corner radius. Defaults to 8.
  final BorderRadius? borderRadius;

  /// Base (trough) colour. Defaults to [UiKitColors.grey200].
  final Color? baseColor;

  /// Highlight (shimmer) colour. Defaults to [UiKitColors.grey100].
  final Color? highlightColor;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
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
    _animation = Tween<double>(begin: -1, end: 2).animate(
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
    final base = widget.baseColor ?? UiKitColors.grey200;
    final highlight = widget.highlightColor ?? UiKitColors.grey100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? const BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [base, highlight, base],
              transform: _SlidingGradientTransform(_animation.value),
            ),
          ),
        );
      },
    );
  }
}

/// Shifts the gradient horizontally to create the shimmer sweep effect.
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * slidePercent,
      0,
      0,
    );
  }
}

// ---------------------------------------------------------------------------

/// Renders [count] shimmer rows that mimic a list of content items.
class ShimmerList extends StatelessWidget {
  const ShimmerList({
    super.key,
    this.count = 5,
    this.itemHeight = 72.0,
    this.spacing = 12.0,
    this.padding,
  });

  /// Number of skeleton rows to show.
  final int count;

  /// Height of each skeleton row.
  final double itemHeight;

  /// Vertical gap between rows.
  final double spacing;

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < count - 1 ? spacing : 0,
            ),
            child: _ShimmerRow(height: itemHeight),
          );
        }),
      ),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox(
          width: height,
          height: height,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(
                width: double.infinity,
                height: 14,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              const SizedBox(height: 8),
              ShimmerBox(
                width: 180,
                height: 12,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
