import 'package:flutter/material.dart';

enum AlertType { info, warning, error, success }

class AlertBanner extends StatelessWidget {
  final AlertType type;
  final String message;
  final String? title;
  final VoidCallback? onDismiss;
  final List<Widget>? actions;

  const AlertBanner({
    super.key,
    required this.type,
    required this.message,
    this.title,
    this.onDismiss,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: config.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(config.icon, size: 18, color: config.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: config.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: config.color.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: actions!
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: a,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
              color: config.color.withOpacity(0.7),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left: 8),
              tooltip: 'Dismiss',
            ),
        ],
      ),
    );
  }

  _AlertConfig _getConfig(AlertType type) {
    switch (type) {
      case AlertType.info:
        return const _AlertConfig(
          color: Color(0xFF58A6FF),
          background: Color(0xFF1F6FEB1A),
          border: Color(0xFF1F6FEB33),
          icon: Icons.info_outline,
        );
      case AlertType.warning:
        return const _AlertConfig(
          color: Color(0xFFD29922),
          background: Color(0xFFD299221A),
          border: Color(0xFFD2992233),
          icon: Icons.warning_amber_outlined,
        );
      case AlertType.error:
        return const _AlertConfig(
          color: Color(0xFFF85149),
          background: Color(0xFFF851491A),
          border: Color(0xFFF8514933),
          icon: Icons.error_outline,
        );
      case AlertType.success:
        return const _AlertConfig(
          color: Color(0xFF3FB950),
          background: Color(0xFF3FB9501A),
          border: Color(0xFF3FB95033),
          icon: Icons.check_circle_outline,
        );
    }
  }
}

class _AlertConfig {
  final Color color;
  final Color background;
  final Color border;
  final IconData icon;

  const _AlertConfig({
    required this.color,
    required this.background,
    required this.border,
    required this.icon,
  });
}
