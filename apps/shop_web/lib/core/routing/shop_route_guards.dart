/// GoRouter redirect guards for the Shop Web application.
library;

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../security/shop_session_manager.dart';
import 'shop_route_names.dart';

/// Provides static redirect callbacks used by [GoRouter] to protect routes.
abstract final class ShopRouteGuards {
  /// The URL path for the login screen – used as the redirect target.
  static const String _loginPath = '/login';

  /// The URL path for the dashboard – used when already authenticated.
  static const String _dashboardPath = '/';

  /// GoRouter [redirect] callback.
  ///
  /// - Unauthenticated users are redirected to the login screen.
  /// - Authenticated users attempting to access the login screen are
  ///   redirected to the dashboard.
  ///
  /// Returns `null` to allow navigation to proceed unchanged.
  static Future<String?> redirect(GoRouterState state) async {
    final sessionManager = GetIt.instance<ShopSessionManager>();
    final isAuthenticated = await sessionManager.isAuthenticated;

    final goingToLogin = state.matchedLocation == _loginPath;

    if (!isAuthenticated && !goingToLogin) {
      // Preserve the intended destination so we can redirect after login.
      final from = Uri.encodeComponent(state.matchedLocation);
      return '$_loginPath?from=$from';
    }

    if (isAuthenticated && goingToLogin) {
      // Already logged in – skip the login screen.
      return _dashboardPath;
    }

    // No redirect needed.
    return null;
  }

  /// Convenience helper that returns the `from` query parameter from [state],
  /// falling back to [_dashboardPath] if it is absent or invalid.
  static String postLoginRedirect(GoRouterState state) {
    final encoded = state.uri.queryParameters['from'];
    if (encoded != null && encoded.isNotEmpty) {
      try {
        return Uri.decodeComponent(encoded);
      } catch (_) {}
    }
    return _dashboardPath;
  }
}
