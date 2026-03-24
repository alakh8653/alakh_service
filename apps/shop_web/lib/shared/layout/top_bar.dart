/// Top application bar for the shop dashboard.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// The dashboard top bar that displays the shop name, a notification bell,
/// and a user avatar with a dropdown menu.
///
/// The hamburger icon is shown on mobile for opening the drawer. On larger
/// screens it is hidden.
class ShopTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a [ShopTopBar].
  const ShopTopBar({
    required this.shopName,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.onLogout,
    this.userAvatarUrl,
    this.onMenuTap,
    super.key,
  });

  /// Name of the shop displayed in the center/left area.
  final String shopName;

  /// Number of unread notifications. Shows a badge when > 0.
  final int notificationCount;

  /// Called when the notification bell is tapped.
  final VoidCallback onNotificationTap;

  /// Called when the "Profile" menu option is selected.
  final VoidCallback onProfileTap;

  /// Called when the "Logout" menu option is selected.
  final VoidCallback onLogout;

  /// Optional URL for the user's avatar image.
  final String? userAvatarUrl;

  /// Called when the hamburger menu icon is tapped (mobile only).
  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: onMenuTap != null
          ? IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Open menu',
              onPressed: onMenuTap,
            )
          : null,
      automaticallyImplyLeading: false,
      title: Text(
        shopName,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      actions: [
        // Notification bell
        _NotificationButton(
          count: notificationCount,
          onTap: onNotificationTap,
        ),
        const SizedBox(width: 4),
        // User avatar with dropdown
        _UserMenu(
          avatarUrl: userAvatarUrl,
          onProfileTap: onProfileTap,
          onLogout: onLogout,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            top: 8,
            right: 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum _MenuOption { profile, settings, logout }

class _UserMenu extends StatelessWidget {
  const _UserMenu({
    required this.onProfileTap,
    required this.onLogout,
    this.avatarUrl,
  });

  final String? avatarUrl;
  final VoidCallback onProfileTap;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<_MenuOption>(
      tooltip: 'Account',
      position: PopupMenuPosition.under,
      onSelected: (option) {
        switch (option) {
          case _MenuOption.profile:
          case _MenuOption.settings:
            onProfileTap();
          case _MenuOption.logout:
            onLogout();
        }
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: colorScheme.primaryContainer,
        child: avatarUrl != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Icon(
                    Icons.person_rounded,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              )
            : Icon(Icons.person_rounded, color: colorScheme.onPrimaryContainer),
      ),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _MenuOption.profile,
          child: Row(children: [
            Icon(Icons.account_circle_outlined, size: 18),
            SizedBox(width: 10),
            Text('Profile'),
          ]),
        ),
        PopupMenuItem(
          value: _MenuOption.settings,
          child: Row(children: [
            Icon(Icons.settings_outlined, size: 18),
            SizedBox(width: 10),
            Text('Settings'),
          ]),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _MenuOption.logout,
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 18, color: Colors.red),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }
}
