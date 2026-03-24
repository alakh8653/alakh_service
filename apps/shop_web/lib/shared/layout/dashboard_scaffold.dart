/// Root scaffold that composes the sidebar, top bar, and page content.
library;

import 'package:flutter/material.dart';
import 'package:shop_web/shared/layout/responsive_layout.dart';
import 'package:shop_web/shared/layout/sidebar.dart';
import 'package:shop_web/shared/layout/top_bar.dart';

/// The root layout scaffold for all authenticated dashboard pages.
///
/// * **Mobile** — sidebar is hidden; a [Drawer] is used instead.
/// * **Tablet** — sidebar is shown in collapsed (icon-only) mode.
/// * **Desktop** — sidebar is shown fully expanded.
///
/// The [child] widget is the page content provided by GoRouter's shell route.
class DashboardScaffold extends StatefulWidget {
  /// Creates a [DashboardScaffold].
  const DashboardScaffold({
    required this.child,
    this.selectedNavIndex = 0,
    this.shopName = 'My Shop',
    this.notificationCount = 0,
    this.userAvatarUrl,
    this.onNotificationTap,
    this.onProfileTap,
    this.onLogout,
    super.key,
  });

  /// The page content from the router shell.
  final Widget child;

  /// Index of the active nav item passed to [ShopSidebar].
  final int selectedNavIndex;

  /// Shop display name shown in the [ShopTopBar].
  final String shopName;

  /// Unread notification count shown in the [ShopTopBar].
  final int notificationCount;

  /// Optional URL for the user avatar.
  final String? userAvatarUrl;

  /// Notification bell tap handler.
  final VoidCallback? onNotificationTap;

  /// Profile menu selection handler.
  final VoidCallback? onProfileTap;

  /// Logout handler.
  final VoidCallback? onLogout;

  @override
  State<DashboardScaffold> createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends State<DashboardScaffold> {
  bool _sidebarCollapsed = false;

  void _toggleCollapse() => setState(() => _sidebarCollapsed = !_sidebarCollapsed);

  ShopTopBar _buildTopBar({VoidCallback? onMenuTap}) {
    return ShopTopBar(
      shopName: widget.shopName,
      notificationCount: widget.notificationCount,
      userAvatarUrl: widget.userAvatarUrl,
      onNotificationTap: widget.onNotificationTap ?? () {},
      onProfileTap: widget.onProfileTap ?? () {},
      onLogout: widget.onLogout ?? () {},
      onMenuTap: onMenuTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileScaffold(
        topBar: _buildTopBar(
          onMenuTap: () => Scaffold.of(context).openDrawer(),
        ),
        sidebar: ShopSidebar(
          selectedIndex: widget.selectedNavIndex,
          isCollapsed: false,
          onToggleCollapse: () {},
        ),
        child: widget.child,
      ),
      tablet: _DesktopScaffold(
        topBar: _buildTopBar(),
        sidebar: ShopSidebar(
          selectedIndex: widget.selectedNavIndex,
          isCollapsed: true,
          onToggleCollapse: _toggleCollapse,
        ),
        child: widget.child,
      ),
      desktop: _DesktopScaffold(
        topBar: _buildTopBar(),
        sidebar: ShopSidebar(
          selectedIndex: widget.selectedNavIndex,
          isCollapsed: _sidebarCollapsed,
          onToggleCollapse: _toggleCollapse,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Desktop / tablet layout: persistent sidebar + top bar.
class _DesktopScaffold extends StatelessWidget {
  const _DesktopScaffold({
    required this.topBar,
    required this.sidebar,
    required this.child,
  });

  final ShopTopBar topBar;
  final ShopSidebar sidebar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          sidebar,
          Expanded(
            child: Column(
              children: [
                topBar,
                Expanded(
                  child: ClipRect(child: child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile layout: sidebar is in a [Drawer], top bar has hamburger icon.
class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold({
    required this.topBar,
    required this.sidebar,
    required this.child,
  });

  final ShopTopBar topBar;
  final ShopSidebar sidebar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar,
      drawer: Drawer(
        width: 240,
        child: SafeArea(child: sidebar),
      ),
      body: child,
    );
  }
}
