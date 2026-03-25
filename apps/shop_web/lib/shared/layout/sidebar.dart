/// Collapsible sidebar navigation for the shop dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_web/core/routing/shop_route_names.dart';

/// Represents a single item in the [ShopSidebar] navigation list.
class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.routeName,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final String routeName;
  final int? badgeCount;
}

/// A vertical navigation sidebar for the shop dashboard.
///
/// Renders the shop logo, a scrollable list of navigation items grouped by
/// section, and a collapse/expand toggle at the bottom.
///
/// When [isCollapsed] is `true`, only icons are shown (rail mode). When
/// `false`, icons + labels are shown (drawer mode).
class ShopSidebar extends StatelessWidget {
  /// Creates a [ShopSidebar].
  const ShopSidebar({
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onToggleCollapse,
    super.key,
  });

  /// Zero-based index of the currently active navigation item.
  final int selectedIndex;

  /// Whether the sidebar is in collapsed (icon-only) mode.
  final bool isCollapsed;

  /// Called when the user taps the collapse/expand toggle.
  final VoidCallback onToggleCollapse;

  static const List<_NavItem> _items = [
    _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, routeName: ShopRouteNames.dashboard),
    _NavItem(label: 'Queue', icon: Icons.queue_outlined, routeName: ShopRouteNames.queue),
    _NavItem(label: 'Bookings', icon: Icons.calendar_month_outlined, routeName: ShopRouteNames.bookings),
    _NavItem(label: 'Staff', icon: Icons.people_outlined, routeName: ShopRouteNames.staff),
    _NavItem(label: 'Earnings', icon: Icons.account_balance_wallet_outlined, routeName: ShopRouteNames.earnings),
    _NavItem(label: 'Analytics', icon: Icons.bar_chart_rounded, routeName: ShopRouteNames.analytics),
    _NavItem(label: 'Settlements', icon: Icons.receipt_long_outlined, routeName: ShopRouteNames.settlements),
    _NavItem(label: 'Compliance', icon: Icons.verified_outlined, routeName: ShopRouteNames.compliance),
    _NavItem(label: 'Settings', icon: Icons.settings_outlined, routeName: ShopRouteNames.settings),
  ];

  static const double _expandedWidth = 240;
  static const double _collapsedWidth = 72;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isCollapsed ? _collapsedWidth : _expandedWidth,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          _Logo(isCollapsed: isCollapsed),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _NavTile(
                  item: _items[index],
                  isSelected: selectedIndex == index,
                  isCollapsed: isCollapsed,
                  onTap: () => context.goNamed(_items[index].routeName),
                );
              },
            ),
          ),
          const Divider(height: 1),
          _CollapseToggle(
            isCollapsed: isCollapsed,
            onToggle: onToggleCollapse,
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.isCollapsed});
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(Icons.storefront_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
          if (!isCollapsed) ...[
            const SizedBox(width: 10),
            Text(
              'ShopPanel',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = widget.isSelected;

    final bg = selected
        ? colorScheme.primaryContainer
        : _hovered
            ? colorScheme.surfaceContainerHighest
            : Colors.transparent;
    final fg = selected ? colorScheme.primary : colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Icon(widget.item.icon, color: fg, size: 22),
                  if (widget.item.badgeCount != null && widget.item.badgeCount! > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (widget.item.badgeCount != null && widget.item.badgeCount! > 0)
                  _CountBadge(count: widget.item.badgeCount!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CollapseToggle extends StatelessWidget {
  const _CollapseToggle({required this.isCollapsed, required this.onToggle});
  final bool isCollapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.end,
          children: [
            Icon(
              isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
