/// Centralised API endpoint constants for the Shop Web application.
library;

/// Provides all REST endpoint paths used by [ShopApiClient].
///
/// All paths are relative to [baseUrl] unless they begin with `http`.
abstract final class ShopApiEndpoints {
  // -------------------------------------------------------------------------
  // Base
  // -------------------------------------------------------------------------

  /// Root URL of the Alakh backend API.
  static const String baseUrl = 'https://api.alakh.app/v1';

  // -------------------------------------------------------------------------
  // Auth
  // -------------------------------------------------------------------------

  /// POST – exchange credentials for tokens.
  static const String login = '/auth/login';

  /// POST – invalidate the current session.
  static const String logout = '/auth/logout';

  /// POST – obtain a new access token using the refresh token.
  static const String refreshToken = '/auth/refresh';

  /// GET – return the profile of the currently authenticated user.
  static const String me = '/auth/me';

  // -------------------------------------------------------------------------
  // Queue
  // -------------------------------------------------------------------------

  /// GET/POST – list or add items to the active queue.
  static const String queue = '/queue';

  /// GET/PATCH/DELETE – operate on a single queue item by id.
  static const String queueItem = '/queue/{id}';

  /// POST – advance the queue to the next customer.
  static const String queueNext = '/queue/next';

  /// POST – pause the queue.
  static const String queuePause = '/queue/pause';

  /// POST – resume a paused queue.
  static const String queueResume = '/queue/resume';

  /// GET/PUT – retrieve or update queue configuration.
  static const String queueSettings = '/queue/settings';

  /// POST – reorder items within the queue.
  static const String queueReorder = '/queue/reorder';

  // -------------------------------------------------------------------------
  // Bookings
  // -------------------------------------------------------------------------

  /// GET/POST – list or create bookings.
  static const String bookings = '/bookings';

  /// GET/PATCH – retrieve or update a booking by id.
  static const String bookingDetail = '/bookings/{id}';

  /// POST – cancel a booking by id.
  static const String bookingCancel = '/bookings/{id}/cancel';

  /// GET – fetch bookings formatted for a calendar view.
  static const String bookingCalendar = '/bookings/calendar';

  // -------------------------------------------------------------------------
  // Staff
  // -------------------------------------------------------------------------

  /// GET/POST – list or create staff members.
  static const String staff = '/staff';

  /// GET/PATCH/DELETE – operate on a single staff member by id.
  static const String staffDetail = '/staff/{id}';

  /// POST – send an invitation email to a prospective staff member.
  static const String staffInvite = '/staff/invite';

  /// GET/PUT – retrieve or update the schedule for a staff member.
  static const String staffSchedule = '/staff/{id}/schedule';

  /// GET/PUT – retrieve or update role assignments for a staff member.
  static const String staffRoles = '/staff/{id}/roles';

  // -------------------------------------------------------------------------
  // Earnings
  // -------------------------------------------------------------------------

  /// GET – summary earnings figures for the shop.
  static const String earnings = '/earnings';

  /// GET – itemised earnings breakdown by service, staff, or period.
  static const String earningsBreakdown = '/earnings/breakdown';

  /// GET – period-over-period earnings comparison.
  static const String earningsCompare = '/earnings/compare';

  // -------------------------------------------------------------------------
  // Analytics
  // -------------------------------------------------------------------------

  /// GET – high-level overview metrics (visits, revenue, new customers, etc.).
  static const String analyticsOverview = '/analytics/overview';

  /// GET – customer demographics and behaviour insights.
  static const String customerInsights = '/analytics/customers';

  /// GET – heatmap data showing busiest hours of the week.
  static const String peakHours = '/analytics/peak-hours';

  /// GET – customer retention and repeat-visit statistics.
  static const String retention = '/analytics/retention';

  // -------------------------------------------------------------------------
  // Settlements
  // -------------------------------------------------------------------------

  /// GET – list of past and pending settlements.
  static const String settlements = '/settlements';

  /// GET – detailed view of a single settlement by id.
  static const String settlementDetail = '/settlements/{id}';

  /// GET/PUT – retrieve or update the shop's linked bank account.
  static const String bankAccount = '/settlements/bank-account';

  /// POST – request an early / instant payout.
  static const String earlyPayout = '/settlements/early-payout';

  // -------------------------------------------------------------------------
  // Compliance
  // -------------------------------------------------------------------------

  /// GET – overall compliance status of the shop.
  static const String complianceStatus = '/compliance/status';

  /// GET – list of required and submitted compliance documents.
  static const String documents = '/compliance/documents';

  /// POST – upload a new compliance document.
  static const String documentUpload = '/compliance/documents/upload';

  /// DELETE – remove a previously uploaded compliance document.
  static const String documentDelete = '/compliance/documents/{id}';

  // -------------------------------------------------------------------------
  // Settings
  // -------------------------------------------------------------------------

  /// GET/PUT – retrieve or update the shop's public profile.
  static const String shopProfile = '/settings/profile';

  /// GET/PUT – retrieve or update the shop's opening hours.
  static const String businessHours = '/settings/business-hours';

  /// GET/POST/DELETE – manage the list of services offered by the shop.
  static const String services = '/settings/services';

  /// GET/PUT – retrieve or update notification preferences.
  static const String notificationSettings = '/settings/notifications';

  // -------------------------------------------------------------------------
  // Dashboard
  // -------------------------------------------------------------------------

  /// GET – aggregated summary card data for the main dashboard.
  static const String dashboardSummary = '/dashboard/summary';

  /// GET – time-series revenue data for the dashboard chart.
  static const String revenueChart = '/dashboard/revenue-chart';

  /// GET – paginated feed of recent shop activity.
  static const String recentActivity = '/dashboard/activity';
}
