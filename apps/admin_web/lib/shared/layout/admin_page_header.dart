import 'package:flutter/material.dart';

class AdminPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;

  const AdminPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!
                  .map((a) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: a,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
