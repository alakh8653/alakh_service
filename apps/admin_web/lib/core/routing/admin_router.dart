import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_web/core/routing/admin_route_names.dart';
import 'package:admin_web/core/routing/admin_route_guards.dart';
import 'package:admin_web/features/auth/presentation/pages/admin_login_page.dart';
import 'package:admin_web/features/city_management/presentation/pages/city_list_page.dart';
import 'package:admin_web/features/shop_approval/presentation/pages/shop_approval_list_page.dart';
import 'package:admin_web/features/dispute_resolution/presentation/pages/dispute_list_page.dart';
import 'package:admin_web/features/fraud_monitoring/presentation/pages/fraud_monitoring_page.dart';
import 'package:admin_web/features/payments_monitoring/presentation/pages/payments_monitoring_page.dart';
import 'package:admin_web/features/trust_engine_control/presentation/pages/trust_engine_control_page.dart';
import 'package:admin_web/features/audit_logs/presentation/pages/audit_logs_page.dart';
import 'package:admin_web/features/analytics_dashboard/presentation/pages/analytics_dashboard_page.dart';
import 'package:admin_web/features/system_health/presentation/pages/system_health_page.dart';

class AdminRouter {
  late final GoRouter router;

  AdminRouter() {
    router = GoRouter(
      initialLocation: AdminRouteNames.dashboard,
      debugLogDiagnostics: false,
      redirect: AdminRouteGuards.authGuard,
      errorBuilder: (context, state) => _ErrorPage(error: state.error),
      routes: [
        GoRoute(
          path: AdminRouteNames.login,
          name: AdminRouteNames.nameLogin,
          builder: (context, state) => const AdminLoginPage(),
        ),
        GoRoute(
          path: AdminRouteNames.dashboard,
          name: AdminRouteNames.nameDashboard,
          builder: (context, state) => const AnalyticsDashboardPage(),
        ),
        GoRoute(
          path: AdminRouteNames.cities,
          name: AdminRouteNames.nameCities,
          builder: (context, state) => const CityListPage(),
          routes: [
            GoRoute(
              path: 'create',
              name: AdminRouteNames.nameCityCreate,
              builder: (context, state) => const CityListPage(showCreateForm: true),
            ),
            GoRoute(
              path: ':id',
              name: AdminRouteNames.nameCityDetail,
              builder: (context, state) => CityListPage(
                detailId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: AdminRouteNames.shops,
          name: AdminRouteNames.nameShops,
          builder: (context, state) => const ShopApprovalListPage(),
          routes: [
            GoRoute(
              path: 'pending',
              name: AdminRouteNames.nameShopsPending,
              builder: (context, state) => const ShopApprovalListPage(showPending: true),
            ),
            GoRoute(
              path: ':id',
              name: AdminRouteNames.nameShopDetail,
              builder: (context, state) => ShopApprovalListPage(
                detailId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: AdminRouteNames.disputes,
          name: AdminRouteNames.nameDisputes,
          builder: (context, state) => const DisputeListPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: AdminRouteNames.nameDisputeDetail,
              builder: (context, state) => DisputeListPage(
                detailId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: AdminRouteNames.fraud,
          name: AdminRouteNames.nameFraud,
          builder: (context, state) => const FraudMonitoringPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: AdminRouteNames.nameFraudAlertDetail,
              builder: (context, state) => FraudMonitoringPage(
                detailId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: AdminRouteNames.payments,
          name: AdminRouteNames.namePayments,
          builder: (context, state) => const PaymentsMonitoringPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: AdminRouteNames.namePaymentDetail,
              builder: (context, state) => PaymentsMonitoringPage(
                detailId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: AdminRouteNames.trust,
          name: AdminRouteNames.nameTrust,
          builder: (context, state) => const TrustEngineControlPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: AdminRouteNames.nameTrustProfile,
              builder: (context, state) => TrustEngineControlPage(
                detailId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: AdminRouteNames.auditLogs,
          name: AdminRouteNames.nameAuditLogs,
          builder: (context, state) => const AuditLogsPage(),
        ),
        GoRoute(
          path: AdminRouteNames.analytics,
          name: AdminRouteNames.nameAnalytics,
          builder: (context, state) => const AnalyticsDashboardPage(),
        ),
        GoRoute(
          path: AdminRouteNames.systemHealth,
          name: AdminRouteNames.nameSystemHealth,
          builder: (context, state) => const SystemHealthPage(),
        ),
      ],
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final Exception? error;
  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFF85149)),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'The requested page does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AdminRouteNames.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
