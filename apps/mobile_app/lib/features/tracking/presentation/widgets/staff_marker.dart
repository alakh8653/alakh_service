import 'package:flutter/material.dart';

/// Animated map marker for the staff member's position.
///
/// Uses a pulsing scale animation to draw attention to the live location.
class StaffMarker extends StatefulWidget {
  /// Colour of the marker dot.
  final Color color;

  /// Size of the marker dot.
  final double size;

  /// Creates a [StaffMarker].
  const StaffMarker({
    super.key,
    this.color = Colors.blue,
    this.size = 20,
  });

  @override
  State<StaffMarker> createState() => _StaffMarkerState();
}

class _StaffMarkerState extends State<StaffMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
