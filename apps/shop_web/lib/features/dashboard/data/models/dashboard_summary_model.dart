import 'package:shop_web/features/dashboard/domain/entities/dashboard_summary.dart';

/// Data model for dashboard summary returned from the API.
///
/// Handles JSON serialization/deserialization and converts to the
/// [DashboardSummary] domain entity.
class DashboardSummaryModel {
  /// Revenue collected today.
  final double todayRevenue;

  /// Total number of bookings.
  final int totalBookings;

  /// Number of customers currently in the active queue.
  final int activeQueue;

  /// Average rating across all reviews.
  final double avgRating;

  /// Number of actions awaiting operator attention.
  final int pendingActions;

  /// Percentage revenue change compared to the previous period.
  final double revenueChange;

  /// Absolute change in bookings compared to the previous period.
  final int bookingsChange;

  const DashboardSummaryModel({
    required this.todayRevenue,
    required this.totalBookings,
    required this.activeQueue,
    required this.avgRating,
    required this.pendingActions,
    required this.revenueChange,
    required this.bookingsChange,
  });

  /// Creates a [DashboardSummaryModel] from a JSON map.
  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      todayRevenue: (json['today_revenue'] as num?)?.toDouble() ?? 0.0,
      totalBookings: (json['total_bookings'] as num?)?.toInt() ?? 0,
      activeQueue: (json['active_queue'] as num?)?.toInt() ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      pendingActions: (json['pending_actions'] as num?)?.toInt() ?? 0,
      revenueChange: (json['revenue_change'] as num?)?.toDouble() ?? 0.0,
      bookingsChange: (json['bookings_change'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'today_revenue': todayRevenue,
      'total_bookings': totalBookings,
      'active_queue': activeQueue,
      'avg_rating': avgRating,
      'pending_actions': pendingActions,
      'revenue_change': revenueChange,
      'bookings_change': bookingsChange,
    };
  }

  /// Converts this model to the [DashboardSummary] domain entity.
  DashboardSummary toEntity() {
    return DashboardSummary(
      todayRevenue: todayRevenue,
      totalBookings: totalBookings,
      activeQueue: activeQueue,
      avgRating: avgRating,
      pendingActions: pendingActions,
      revenueChange: revenueChange,
      bookingsChange: bookingsChange,
    );
  }
}
