import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_web/core/routing/admin_route_names.dart';
import 'package:admin_web/core/security/admin_session_manager.dart';
import 'package:admin_web/core/di/injection_container.dart';

class _NavItem {
  final IconData icon;
  final String label;
  final String path;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}

const _navItems = [
  _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', path: AdminRouteNames.dashboard),
  _NavItem(icon: Icons.location_city_outlined, label: 'Cities', path: AdminRouteNames.cities),
  _NavItem(icon: Icons.store_outlined, label: 'Shops', path: AdminRouteNames.shops),
  _NavItem(icon: Icons.gavel_outlined, label: 'Disputes', path: AdminRouteNames.disputes),
  _NavItem(icon: Icons.security_outlined, label: 'Fraud', path: AdminRouteNames.fraud),
  _NavItem(icon: Icons.payment_outlined, label: 'Payments', path: AdminRouteNames.payments),
  _NavItem(icon: Icons.verified_user_outlined, label: 'Trust Engine', path: AdminRouteNames.trust),
  _NavItem(icon: Icons.history_outlined, label: 'Audit Logs', path: AdminRouteNames.auditLogs),
  _NavItem(icon: Icons.analytics_outlined, label: 'Analytics', path: AdminRouteNames.analytics),
  _NavItem(icon: Icons.monitor_heart_outlined, label: 'System Health', path: AdminRouteNames.systemHealth),
];

class AdminSidebar extends StatefulWidget {
  const AdminSidebar({super.key});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  bool _collapsed = false;

  static const double _expandedWidth = 240;
  static const double _collapsedWidth = 72;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isLarge = MediaQuery.of(context).size.width > 1200;

    if (!isLarge) {
      return _buildRail(currentPath);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _collapsed ? _collapsedWidth : _expandedWidth,
      child: _buildFullSidebar(currentPath),
    );
  }

  Widget _buildFullSidebar(String currentPath) {
    final theme = Theme.of(context);
    const border = Color(0xFF30363D);
    const surface = Color(0xFF161B22);

    return Container(
      color: surface,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: border)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isActive = _isActive(currentPath, item.path);
                return _buildNavTile(item, isActive, theme);
              },
            ),
          ),
          _buildUserFooter(),
          _buildCollapseButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1F6FEB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 18),
          ),
          if (!_collapsed) ...[
            const SizedBox(width: 10),
            const Text(
              'Alakh Admin',
              style: TextStyle(
                color: Color(0xFFC9D1D9),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavTile(_NavItem item, bool isActive, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => context.go(item.path),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1F6FEB1A) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: isActive
                      ? const Color(0xFF1F6FEB)
                      : const Color(0xFF8B949E),
                ),
                if (!_collapsed) ...[
                  const SizedBox(width: 10),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF1F6FEB)
                          : const Color(0xFFC9D1D9),
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserFooter() {
    final sessionManager = getIt<AdminSessionManager>();
    final user = sessionManager.getUser();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF30363D))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF1F6FEB),
            child: Text(
              user?.name.isNotEmpty == true
                  ? user!.name[0].toUpperCase()
                  : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!_collapsed && user != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Color(0xFFC9D1D9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user.role.name,
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IconButton(
        icon: Icon(
          _collapsed ? Icons.chevron_right : Icons.chevron_left,
          color: const Color(0xFF8B949E),
          size: 18,
        ),
        onPressed: () => setState(() => _collapsed = !_collapsed),
        tooltip: _collapsed ? 'Expand' : 'Collapse',
      ),
    );
  }

  Widget _buildRail(String currentPath) {
    final selectedIndex = _navItems.indexWhere(
      (item) => _isActive(currentPath, item.path),
    );

    return NavigationRail(
      extended: false,
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (index) => context.go(_navItems[index].path),
      leading: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1F6FEB),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.bolt, color: Colors.white, size: 20),
      ),
      destinations: _navItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            ),
          )
          .toList(),
    );
  }

  bool _isActive(String currentPath, String itemPath) {
    if (itemPath == AdminRouteNames.dashboard) {
      return currentPath == AdminRouteNames.dashboard ||
          currentPath == AdminRouteNames.analytics;
    }
    return currentPath.startsWith(itemPath);
  }
}
