import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_web/core/routing/admin_route_names.dart';
import 'package:admin_web/core/security/admin_auth_service.dart';
import 'package:admin_web/core/security/admin_session_manager.dart';
import 'package:admin_web/core/di/injection_container.dart';
import 'package:admin_web/shared/layout/admin_breadcrumb.dart';

class AdminTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final List<BreadcrumbItem>? breadcrumbs;
  final bool showMenuButton;

  const AdminTopBar({
    super.key,
    required this.title,
    this.actions,
    this.breadcrumbs,
    this.showMenuButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const border = Color(0xFF30363D);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: const Border(bottom: BorderSide(color: border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showMenuButton)
            IconButton(
              icon: const Icon(Icons.menu, size: 20),
              onPressed: () => Scaffold.of(context).openDrawer(),
              color: const Color(0xFF8B949E),
            ),
          if (!showMenuButton) const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFFC9D1D9),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null) ...actions!,
          const SizedBox(width: 8),
          _NotificationBell(),
          const SizedBox(width: 8),
          _UserMenu(),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 20),
          onPressed: () {},
          color: const Color(0xFF8B949E),
          tooltip: 'Notifications',
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1F6FEB),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _UserMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sessionManager = getIt<AdminSessionManager>();
    final user = sessionManager.getUser();

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(width: 6),
          Text(
            user?.name ?? 'Admin',
            style: const TextStyle(
              color: Color(0xFFC9D1D9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: Color(0xFF8B949E),
          ),
        ],
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: Color(0xFF8B949E)),
              SizedBox(width: 8),
              Text('Profile', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 16, color: Color(0xFF8B949E)),
              SizedBox(width: 8),
              Text('Settings', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16, color: Color(0xFFF85149)),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(fontSize: 13, color: Color(0xFFF85149)),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'logout') {
          final authService = getIt<AdminAuthService>();
          await authService.logout();
          if (context.mounted) {
            context.go(AdminRouteNames.login);
          }
        }
      },
    );
  }
}
