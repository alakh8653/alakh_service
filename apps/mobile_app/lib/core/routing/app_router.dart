/// Main router configuration for the mobile app.
///
/// Uses GoRouter for declarative, URL-based routing with nested navigation
/// and route guards.  Import the `go_router` package in `pubspec.yaml`:
///
/// ```yaml
/// dependencies:
///   go_router: ^14.0.0
/// ```
library app_router;

import 'package:flutter/material.dart';
// TODO: Uncomment when go_router is added to pubspec.yaml
// import 'package:go_router/go_router.dart';

import 'route_guards.dart';
import 'route_names.dart';

/// Builds and configures the application router.
///
/// Call [AppRouter.create] once (typically inside a Riverpod provider or DI
/// container) and pass the returned router to [MaterialApp.router].
///
/// ```dart
/// final router = AppRouter.create(
///   routeGuardContext: ref.watch(routeGuardContextProvider),
/// );
/// MaterialApp.router(routerConfig: router);
/// ```
class AppRouter {
  AppRouter._();

  // TODO: Replace with a GoRouter instance when go_router is available.
  // static GoRouter create({required RouteGuardContext routeGuardContext}) {
  //   return GoRouter(
  //     initialLocation: RouteNames.splashPath,
  //     debugLogDiagnostics: true,
  //     redirect: (context, state) => _globalRedirect(routeGuardContext, state),
  //     routes: [
  //       _splashRoute(),
  //       _onboardingRoute(),
  //       _authRoutes(),
  //       _mainShellRoute(),
  //       _staffModeRoute(),
  //       GoRoute(
  //         path: RouteNames.notFoundPath,
  //         name: RouteNames.notFound,
  //         builder: (ctx, state) => const NotFoundPage(),
  //       ),
  //     ],
  //     errorBuilder: (ctx, state) => ErrorPage(error: state.error),
  //   );
  // }

  /// Global redirect that runs before every route transition.
  ///
  /// Guards are evaluated in order; the first non-null redirect wins.
  // static String? _globalRedirect(
  //   RouteGuardContext ctx,
  //   GoRouterState state,
  // ) {
  //   final path = state.uri.toString();
  //
  //   // Always allow the splash screen
  //   if (path == RouteNames.splashPath) return null;
  //
  //   // Auth-protected routes
  //   final authRoutes = [
  //     RouteNames.mainShellPath,
  //     RouteNames.staffModePath,
  //   ];
  //   if (authRoutes.any(path.startsWith)) {
  //     return RouteGuards.compose(ctx, path, [
  //       RouteGuards.authGuard,
  //       RouteGuards.onboardingGuard,
  //     ]);
  //   }
  //
  //   // Staff-only routes
  //   if (path.startsWith(RouteNames.staffModePath)) {
  //     return RouteGuards.staffGuard(ctx, path);
  //   }
  //
  //   // Guest routes – redirect authenticated users away from login/register
  //   final guestRoutes = [RouteNames.authRootPath];
  //   if (guestRoutes.any(path.startsWith)) {
  //     return RouteGuards.guestGuard(ctx, path);
  //   }
  //
  //   return null;
  // }

  // ── Individual route builders ─────────────────────────────────────────────

  // static GoRoute _splashRoute() => GoRoute(
  //   path: RouteNames.splashPath,
  //   name: RouteNames.splash,
  //   builder: (ctx, state) => const SplashPage(),
  // );
  //
  // static GoRoute _onboardingRoute() => GoRoute(
  //   path: RouteNames.onboardingPath,
  //   name: RouteNames.onboarding,
  //   builder: (ctx, state) => const OnboardingPage(),
  // );
  //
  // static GoRoute _authRoutes() => GoRoute(
  //   path: RouteNames.authRootPath,
  //   name: RouteNames.authRoot,
  //   redirect: (ctx, state) {
  //     if (state.uri.toString() == RouteNames.authRootPath) {
  //       return '${RouteNames.authRootPath}/${RouteNames.loginPath}';
  //     }
  //     return null;
  //   },
  //   routes: [
  //     GoRoute(
  //       path: RouteNames.loginPath,
  //       name: RouteNames.login,
  //       builder: (ctx, state) => const LoginPage(),
  //     ),
  //     GoRoute(
  //       path: RouteNames.registerPath,
  //       name: RouteNames.register,
  //       builder: (ctx, state) => const RegisterPage(),
  //     ),
  //     GoRoute(
  //       path: RouteNames.forgotPasswordPath,
  //       name: RouteNames.forgotPassword,
  //       builder: (ctx, state) => const ForgotPasswordPage(),
  //     ),
  //     GoRoute(
  //       path: RouteNames.verifyOtpPath,
  //       name: RouteNames.verifyOtp,
  //       builder: (ctx, state) {
  //         final phone = state.uri.queryParameters['phone'] ?? '';
  //         return VerifyOtpPage(phone: phone);
  //       },
  //     ),
  //   ],
  // );
  //
  // static ShellRoute _mainShellRoute() => ShellRoute(
  //   builder: (ctx, state, child) => MainShell(child: child),
  //   routes: [
  //     GoRoute(
  //       path: '${RouteNames.mainShellPath}/${RouteNames.discoveryPath}',
  //       name: RouteNames.discovery,
  //       builder: (ctx, state) => const DiscoveryPage(),
  //       routes: [
  //         GoRoute(
  //           path: RouteNames.shopDetailPath,
  //           name: RouteNames.shopDetail,
  //           builder: (ctx, state) {
  //             final shopId = state.pathParameters['shopId']!;
  //             return ShopDetailPage(shopId: shopId);
  //           },
  //         ),
  //       ],
  //     ),
  //     GoRoute(
  //       path: '${RouteNames.mainShellPath}/${RouteNames.bookingPath}',
  //       name: RouteNames.booking,
  //       builder: (ctx, state) => const BookingPage(),
  //     ),
  //     GoRoute(
  //       path: '${RouteNames.mainShellPath}/${RouteNames.queuePath}',
  //       name: RouteNames.queue,
  //       builder: (ctx, state) => const QueuePage(),
  //     ),
  //     GoRoute(
  //       path: '${RouteNames.mainShellPath}/${RouteNames.paymentsPath}',
  //       name: RouteNames.payments,
  //       builder: (ctx, state) => const PaymentsPage(),
  //     ),
  //     GoRoute(
  //       path: '${RouteNames.mainShellPath}/${RouteNames.profilePath}',
  //       name: RouteNames.profile,
  //       builder: (ctx, state) => const ProfilePage(),
  //     ),
  //   ],
  // );
  //
  // static GoRoute _staffModeRoute() => GoRoute(
  //   path: RouteNames.staffModePath,
  //   name: RouteNames.staffMode,
  //   builder: (ctx, state) => const StaffModePage(),
  //   routes: [
  //     GoRoute(
  //       path: RouteNames.staffDashboardPath,
  //       name: RouteNames.staffDashboard,
  //       builder: (ctx, state) => const StaffDashboardPage(),
  //     ),
  //     GoRoute(
  //       path: RouteNames.dispatchPath,
  //       name: RouteNames.dispatch,
  //       builder: (ctx, state) => const DispatchPage(),
  //     ),
  //   ],
  // );

  /// Placeholder navigator for use before GoRouter integration.
  ///
  /// Replace with [GoRouter] once the dependency is added.
  static MaterialApp buildFallbackApp({required Widget home}) =>
      MaterialApp(home: home);
}
