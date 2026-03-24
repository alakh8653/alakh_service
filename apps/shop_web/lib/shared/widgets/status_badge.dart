/// Coloured status badge widget with semantic type variants.
library;

import 'package:flutter/material.dart';

/// Semantic colour categories for [StatusBadge].
enum StatusType {
  /// Operation succeeded / active / enabled.
  success,

  /// Caution or soft warning.
  warning,

  /// Critical failure or rejection.
  error,

  /// Informational / neutral-positive.
  info,

  /// Work in progress or awaiting action.
  pending,

  /// Inactive, disabled, or not applicable.
  neutral,
}

/// A small, pill-shaped badge that communicates status at a glance.
///
/// ```dart
/// StatusBadge(label: 'Confirmed', type: StatusType.success)
/// ```
class StatusBadge extends StatelessWidget {
  /// Creates a [StatusBadge].
  const StatusBadge({
    required this.label,
    required this.type,
    super.key,
  });

  /// Text displayed inside the badge.
  final String label;

  /// Semantic type that controls the badge colour scheme.
  final StatusType type;

  @override
  Widget build(BuildContext context) {
    final scheme = _schemeFor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.border, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.foreground,
        ),
      ),
    );
  }

  static _BadgeColorScheme _schemeFor(StatusType type) {
    switch (type) {
      case StatusType.success:
        return _BadgeColorScheme(
          background: Colors.green.shade50,
          foreground: Colors.green.shade800,
          border: Colors.green.shade200,
        );
      case StatusType.warning:
        return _BadgeColorScheme(
          background: Colors.orange.shade50,
          foreground: Colors.orange.shade800,
          border: Colors.orange.shade200,
        );
      case StatusType.error:
        return _BadgeColorScheme(
          background: Colors.red.shade50,
          foreground: Colors.red.shade800,
          border: Colors.red.shade200,
        );
      case StatusType.info:
        return _BadgeColorScheme(
          background: Colors.blue.shade50,
          foreground: Colors.blue.shade800,
          border: Colors.blue.shade200,
        );
      case StatusType.pending:
        return _BadgeColorScheme(
          background: Colors.amber.shade50,
          foreground: Colors.amber.shade900,
          border: Colors.amber.shade200,
        );
      case StatusType.neutral:
        return _BadgeColorScheme(
          background: Colors.grey.shade100,
          foreground: Colors.grey.shade700,
          border: Colors.grey.shade300,
        );
    }
  }
}

class _BadgeColorScheme {
  const _BadgeColorScheme({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
