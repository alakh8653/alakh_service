class AdminApiEndpoints {
  AdminApiEndpoints._();

  // Cities
  static const String cities = '/admin/cities';
  static const String cityById = '/admin/cities/{id}';

  // Shops
  static const String shops = '/admin/shops';
  static const String shopsPending = '/admin/shops/pending';
  static const String shopApprove = '/admin/shops/{id}/approve';
  static const String shopReject = '/admin/shops/{id}/reject';
  static const String shopById = '/admin/shops/{id}';

  // Disputes
  static const String disputes = '/admin/disputes';
  static const String disputeById = '/admin/disputes/{id}';
  static const String disputeResolve = '/admin/disputes/{id}/resolve';

  // Fraud
  static const String fraudAlerts = '/admin/fraud/alerts';
  static const String fraudAlertById = '/admin/fraud/alerts/{id}';
  static const String fraudAccounts = '/admin/fraud/accounts';

  // Payments
  static const String payments = '/admin/payments';
  static const String paymentById = '/admin/payments/{id}';
  static const String paymentRefund = '/admin/payments/{id}/refund';

  // Trust Engine
  static const String trustScores = '/admin/trust/scores';
  static const String trustRules = '/admin/trust/rules';
  static const String trustProfileById = '/admin/trust/profiles/{id}';

  // Audit Logs
  static const String auditLogs = '/admin/audit-logs';
  static const String auditLogById = '/admin/audit-logs/{id}';

  // Analytics
  static const String analyticsOverview = '/admin/analytics/overview';
  static const String analyticsRevenue = '/admin/analytics/revenue';
  static const String analyticsUsers = '/admin/analytics/users';

  // System Health
  static const String systemHealth = '/admin/system/health';
  static const String systemMetrics = '/admin/system/metrics';
  static const String systemServices = '/admin/system/services';

  // Auth
  static const String authLogin = '/admin/auth/login';
  static const String authLogout = '/admin/auth/logout';
  static const String authRefresh = '/admin/auth/refresh';

  static String withId(String base, String id) => base.replaceAll('{id}', id);
}
