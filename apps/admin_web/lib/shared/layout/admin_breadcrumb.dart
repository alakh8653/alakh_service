import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BreadcrumbItem {
  final String label;
  final String? path;

  const BreadcrumbItem({required this.label, this.path});
}

class AdminBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const AdminBreadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    const separator = Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '/',
        style: TextStyle(color: Color(0xFF8B949E), fontSize: 12),
      ),
    );

    final children = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      if (i > 0) children.add(separator);

      if (isLast) {
        children.add(
          Text(
            item.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFC9D1D9),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        );
      } else {
        children.add(
          InkWell(
            onTap: item.path != null ? () => context.go(item.path!) : null,
            borderRadius: BorderRadius.circular(3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              child: Text(
                item.label,
                style: const TextStyle(
                  color: Color(0xFF1F6FEB),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
