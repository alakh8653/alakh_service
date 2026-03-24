/// Three-dot popup action menu for table rows and cards.
library;

import 'package:flutter/material.dart';

/// A single entry in an [ActionMenu].
class ActionMenuItem {
  /// Creates an [ActionMenuItem].
  const ActionMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  /// Display label for the menu item.
  final String label;

  /// Leading icon.
  final IconData icon;

  /// Called when the user selects this item.
  final VoidCallback onTap;

  /// When `true`, the item label and icon are rendered in red to signal a
  /// destructive action (e.g. Delete, Remove).
  final bool isDestructive;
}

/// A compact three-dot icon button that opens a [PopupMenuButton] with a list
/// of [ActionMenuItem]s.
///
/// Destructive items are automatically coloured red.
class ActionMenu extends StatelessWidget {
  /// Creates an [ActionMenu].
  const ActionMenu({
    required this.items,
    super.key,
  });

  /// The list of actions to display in the popup menu.
  final List<ActionMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: 'More actions',
      position: PopupMenuPosition.under,
      onSelected: (index) => items[index].onTap(),
      itemBuilder: (_) {
        return List.generate(items.length, (i) {
          final item = items[i];
          final color = item.isDestructive ? Colors.red.shade700 : theme.colorScheme.onSurface;

          return PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                Icon(item.icon, size: 18, color: color),
                const SizedBox(width: 10),
                Text(
                  item.label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
