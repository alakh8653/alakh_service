import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/location.dart';

/// Full-screen placeholder map widget that renders the staff's current
/// position and destination using custom painting.
///
/// TODO: Integrate a proper maps SDK (e.g. google_maps_flutter or
/// flutter_map) to replace the placeholder canvas.
class LiveMapWidget extends StatefulWidget {
  /// The staff member's current location. Null when unavailable.
  final Location? staffLocation;

  /// The destination / customer location. Null when unavailable.
  final Location? destinationLocation;

  /// Encoded polyline for the route. Null when unavailable.
  final String? routePolyline;

  /// Creates a [LiveMapWidget].
  const LiveMapWidget({
    super.key,
    this.staffLocation,
    this.destinationLocation,
    this.routePolyline,
  });

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends State<LiveMapWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F0E8),
      child: Stack(
        children: [
          // TODO: Replace with a real map SDK widget.
          CustomPaint(
            painter: _MapPlaceholderPainter(
              hasStaff: widget.staffLocation != null,
              hasDestination: widget.destinationLocation != null,
            ),
            child: const SizedBox.expand(),
          ),
          if (widget.staffLocation != null)
            Center(
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Map preview — SDK integration pending',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholderPainter extends CustomPainter {
  final bool hasStaff;
  final bool hasDestination;

  const _MapPlaceholderPainter({
    required this.hasStaff,
    required this.hasDestination,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (hasDestination) {
      final destPaint = Paint()..color = Colors.red.withOpacity(0.7);
      canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.35),
        10,
        destPaint,
      );
    }

    if (hasStaff && hasDestination) {
      final routePaint = Paint()
        ..color = Colors.blue.withOpacity(0.5)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(size.width / 2, size.height / 2)
        ..quadraticBezierTo(
          size.width * 0.55,
          size.height * 0.4,
          size.width * 0.6,
          size.height * 0.35,
        );
      canvas.drawPath(path, routePaint);
    }
  }

  @override
  bool shouldRepaint(_MapPlaceholderPainter old) =>
      old.hasStaff != hasStaff || old.hasDestination != hasDestination;
}
