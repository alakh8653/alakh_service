/// Route guards / redirects for authentication, onboarding, and role checks.
///
/// Each guard is a standalone function with the signature expected by
/// GoRouter's `redirect` callback so they can be composed easily.
library route_guards;

/// Represents the current auth + onboarding state fed to route guards.
///
/// In production this would be derived from the session / auth stream.
class RouteGuardContext {
  const RouteGuardContext({
    required this.isAuthenticated,
    required this.hasCompletedOnboarding,
    required this.isStaffMember,
    required this.isAdmin,
  });

  /// Whether a valid session token exists.
  final bool isAuthenticated;

  /// Whether the user has completed the onboarding flow.
  final bool hasCompletedOnboarding;

  /// Whether the authenticated user has the `staff` role.
  final bool isStaffMember;

  /// Whether the authenticated user has the `admin` role.
  final bool isAdmin;
}

/// Collection of route guard / redirect helpers.
///
/// Usage inside a GoRouter redirect callback:
/// ```dart
/// redirect: (context, state) {
///   final ctx = ref.read(routeGuardContextProvider);
///   return RouteGuards.authGuard(ctx, state.uri.toString());
/// }
/// ```
abstract final class RouteGuards {
  RouteGuards._();

  // ── Auth guard ────────────────────────────────────────────────────────────

  /// Redirects unauthenticated users to `/auth/login`.
  ///
  /// Returns `null` when the user is already authenticated (no redirect).
  static String? authGuard(
    RouteGuardContext ctx,
    String currentPath,
  ) {
    if (!ctx.isAuthenticated) {
      return '/auth/login';
    }
    return null;
  }

  // ── Onboarding guard ──────────────────────────────────────────────────────

  /// Redirects users who have not yet completed onboarding to `/onboarding`.
  ///
  /// Returns `null` when onboarding is done.
  static String? onboardingGuard(
    RouteGuardContext ctx,
    String currentPath,
  ) {
    if (ctx.isAuthenticated && !ctx.hasCompletedOnboarding) {
      // Avoid redirect loop if already on onboarding
      if (currentPath.startsWith('/onboarding')) return null;
      return '/onboarding';
    }
    return null;
  }

  // ── Staff guard ───────────────────────────────────────────────────────────

  /// Redirects non-staff users who try to access staff-only routes.
  ///
  /// Returns `null` when the user has the staff role.
  static String? staffGuard(
    RouteGuardContext ctx,
    String currentPath,
  ) {
    if (!ctx.isStaffMember) {
      return '/main/discovery';
    }
    return null;
  }

  // ── Admin guard ───────────────────────────────────────────────────────────

  /// Redirects non-admin users away from admin-only routes.
  ///
  /// Returns `null` when the user has the admin role.
  static String? adminGuard(
    RouteGuardContext ctx,
    String currentPath,
  ) {
    if (!ctx.isAdmin) {
      return '/main/discovery';
    }
    return null;
  }

  // ── Guest guard (inverse auth) ────────────────────────────────────────────

  /// Redirects already-authenticated users away from public pages
  /// such as login or register.
  ///
  /// Returns `null` when the user is a guest (not authenticated).
  static String? guestGuard(
    RouteGuardContext ctx,
    String currentPath,
  ) {
    if (ctx.isAuthenticated) {
      if (ctx.hasCompletedOnboarding) {
        return '/main/discovery';
      }
      return '/onboarding';
    }
    return null;
  }

  // ── Composite guard ───────────────────────────────────────────────────────

  /// Runs multiple guards in order and returns the first non-null redirect.
  ///
  /// Useful when a route needs both authentication AND onboarding checks:
  /// ```dart
  /// redirect: (context, state) => RouteGuards.compose(
  ///   ctx,
  ///   state.uri.toString(),
  ///   [RouteGuards.authGuard, RouteGuards.onboardingGuard],
  /// ),
  /// ```
  static String? compose(
    RouteGuardContext ctx,
    String currentPath,
    List<String? Function(RouteGuardContext, String)> guards,
  ) {
    for (final guard in guards) {
      final redirect = guard(ctx, currentPath);
      if (redirect != null) return redirect;
    }
    return null;
  }
}
