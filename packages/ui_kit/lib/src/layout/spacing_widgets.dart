import 'package:flutter/material.dart';

/// A flexible gap widget that expands in both axes.
///
/// When used inside a [Row] it acts as horizontal space; inside a [Column] as
/// vertical space. For explicit single-axis gaps prefer [HGap] or [VGap].
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  /// Size (in logical pixels) of the gap in both directions.
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}

/// A fixed-height vertical gap — for use inside [Column] or [Flex] with
/// [Axis.vertical].
class VGap extends StatelessWidget {
  const VGap(this.size, {super.key});

  /// Height of the gap in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

/// A fixed-width horizontal gap — for use inside [Row] or [Flex] with
/// [Axis.horizontal].
class HGap extends StatelessWidget {
  const HGap(this.size, {super.key});

  /// Width of the gap in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size);
}
