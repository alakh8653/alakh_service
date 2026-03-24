import 'package:flutter/material.dart';

class TrustShieldIcon extends StatefulWidget {
  final double score;
  final double size;

  const TrustShieldIcon({
    super.key,
    required this.score,
    this.size = 48,
  });

  @override
  State<TrustShieldIcon> createState() => _TrustShieldIconState();
}

class _TrustShieldIconState extends State<TrustShieldIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _shieldColor() {
    if (widget.score >= 80) return Colors.green;
    if (widget.score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _levelLabel() {
    if (widget.score >= 80) return 'HIGH';
    if (widget.score >= 60) return 'MED';
    return 'LOW';
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.shield,
            size: widget.size,
            color: _shieldColor(),
          ),
          Text(
            _levelLabel(),
            style: TextStyle(
              fontSize: widget.size * 0.2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
