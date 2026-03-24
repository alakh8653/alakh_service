import 'package:flutter/material.dart';

class TrustComponentBar extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;

  const TrustComponentBar({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ??
        (value >= 80
            ? Colors.green
            : value >= 60
                ? Colors.orange
                : Colors.red);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: barColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
