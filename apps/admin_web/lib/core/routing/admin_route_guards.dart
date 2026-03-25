import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_web/core/routing/admin_route_names.dart';
import 'package:admin_web/core/security/admin_session_manager.dart';
import 'package:admin_web/core/security/rbac_service.dart';
import 'package:admin_web/core/security/admin_auth_service.dart';
import 'package:admin_web/core/di/injection_container.dart';

class AdminRouteGuards {
  AdminRouteGuards._();

  static String? authGuard(BuildContext context, GoRouterState state) {
    final sessionManager = getIt<AdminSessionManager>();
    final isAuthenticated = sessionManager.isSessionValid();

    if (!isAuthenticated) {
      final loginPath = AdminRouteNames.login;
      if (state.matchedLocation == loginPath) return null;
      return '$loginPath?redirect=${Uri.encodeComponent(state.uri.toString())}';
    }

    if (state.matchedLocation == AdminRouteNames.login) {
      return AdminRouteNames.dashboard;
    }

    return null;
  }

  static GoRouterRedirect roleGuard(List<Permission> required) {
    return (BuildContext context, GoRouterState state) {
      if (required.isEmpty) return null;

      final sessionManager = getIt<AdminSessionManager>();
      final rbacService = getIt<RbacService>();

      final user = sessionManager.getUser();
      if (user == null) return AdminRouteNames.login;

      final canAccess = rbacService.canAccess(required, user.role);
      if (!canAccess) return AdminRouteNames.dashboard;

      return null;
    };
  }
}
