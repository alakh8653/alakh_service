/// Application router configuration for the Shop Web application.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shop_route_guards.dart';
import 'shop_route_names.dart';

// ---------------------------------------------------------------------------
// Placeholder page widgets
// TODO(routing): Replace each placeholder with the real page import once the
// feature pages are implemented.
// ---------------------------------------------------------------------------

/// Temporary scaffold displayed while a page widget is not yet implemented.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('$title – coming soon')),
      );
}

// ---------------------------------------------------------------------------
// Dashboard shell scaffold
// ---------------------------------------------------------------------------

/// Shell scaffold that wraps all authenticated routes with the persistent
/// side-navigation drawer and top app-bar.
///
/// TODO(routing): Replace with the real DashboardScaffold widget once it is
/// implemented in the features layer.
class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: navigationShell,
      );
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

/// Configures and exposes the application-wide [GoRouter] instance.
class ShopRouter {
  ShopRouter._();

  /// The singleton [GoRouter] used by [MaterialApp.router].
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    redirect: ShopRouteGuards.redirect,
    routes: [
      // -----------------------------------------------------------------------
      // Authenticated shell routes
      // -----------------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            DashboardScaffold(navigationShell: navigationShell),
        branches: [
          // Branch 0 – Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: ShopRouteNames.dashboard,
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Dashboard'),
              ),
            ],
          ),

          // Branch 1 – Queue
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/queue',
                name: ShopRouteNames.queue,
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Queue'),
              ),
            ],
          ),

          // Branch 2 – Bookings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                name: ShopRouteNames.bookings,
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Bookings'),
                routes: [
                  GoRoute(
                    path: 'calendar',
                    name: ShopRouteNames.bookingCalendar,
                    builder: (_, __) =>
                        const _PlaceholderPage(title: 'Booking Calendar'),
                  ),
                  GoRoute(
                    path: ':id',
                    name: ShopRouteNames.bookingDetail,
                    builder: (_, state) => _PlaceholderPage(
                      title: 'Booking #${state.pathParameters['id']}',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 3 – Staff
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff',
                name: ShopRouteNames.staff,
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Staff'),
                routes: [
                  GoRoute(
                    path: 'invite',
                    name: ShopRouteNames.staffInvite,
                    builder: (_, __) =>
                        const _PlaceholderPage(title: 'Invite Staff'),
                  ),
                  GoRoute(
                    path: ':id',
                    name: ShopRouteNames.staffDetail,
                    builder: (_, state) => _PlaceholderPage(
                      title: 'Staff #${state.pathParameters['id']}',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 4 – Earnings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/earnings',
                name: ShopRouteNames.earnings,
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Earnings'),
              ),
            ],
          ),

          // Branch 5 – Analytics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                name: ShopRouteNames.analytics,
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Analytics'),
              ),
            ],
          ),

          // Branch 6 – Settlements
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settlements',
                name: ShopRouteNames.settlements,
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Settlements'),
                routes: [
                  GoRoute(
                    path: 'bank',
                    name: ShopRouteNames.bankSettings,
                    builder: (_, __) =>
                        const _PlaceholderPage(title: 'Bank Settings'),
                  ),
                  GoRoute(
                    path: ':id',
                    name: ShopRouteNames.settlementDetail,
                    builder: (_, state) => _PlaceholderPage(
                      title: 'Settlement #${state.pathParameters['id']}',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 7 – Compliance
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/compliance',
                name: ShopRouteNames.compliance,
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Compliance'),
                routes: [
                  GoRoute(
                    path: 'upload',
                    name: ShopRouteNames.uploadDocument,
                    builder: (_, __) =>
                        const _PlaceholderPage(title: 'Upload Document'),
                  ),
                ],
              ),
            ],
          ),

          // Branch 8 – Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: ShopRouteNames.settings,
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Settings'),
                routes: [
                  GoRoute(
                    path: 'profile',
                    name: ShopRouteNames.shopProfile,
                    builder: (_, __) =>
                        const _PlaceholderPage(title: 'Shop Profile'),
                  ),
                  GoRoute(
                    path: 'hours',
                    name: ShopRouteNames.businessHours,
                    builder: (_, __) =>
                        const _PlaceholderPage(title: 'Business Hours'),
                  ),
                  GoRoute(
                    path: 'services',
                    name: ShopRouteNames.services,
                    builder: (_, __) =>
                        const _PlaceholderPage(title: 'Services'),
                  ),
                  GoRoute(
                    path: 'notifications',
                    name: ShopRouteNames.notificationSettings,
                    builder: (_, __) =>
                        const _PlaceholderPage(title: 'Notification Settings'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // -----------------------------------------------------------------------
      // Unauthenticated routes (outside the shell)
      // -----------------------------------------------------------------------
      GoRoute(
        path: '/login',
        name: ShopRouteNames.login,
        builder: (_, __) => const _PlaceholderPage(title: 'Login'),
      ),
    ],
  );
}
