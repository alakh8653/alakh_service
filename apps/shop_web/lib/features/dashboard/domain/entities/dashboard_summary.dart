import 'package:equatable/equatable.dart';

/// Domain entity representing the high-level dashboard summary.
///
/// Carries key performance indicators shown at the top of the Dashboard page.
class DashboardSummary extends Equatable {
  /// Revenue collected today, in the shop's base currency.
  final double todayRevenue;

  /// Total number of bookings recorded so far today.
  final int totalBookings;

  /// Number of customers currently waiting in the active queue.
  final int activeQueue;

  /// Average star rating across all published reviews.
  final double avgRating;

  /// Number of operator actions waiting to be addressed.
  final int pendingActions;

  /// Percentage change in revenue compared to the equivalent previous period.
  ///
  /// A positive value indicates growth; negative indicates decline.
  final double revenueChange;

  /// Absolute change in booking count compared to the previous period.
  final int bookingsChange;

  const DashboardSummary({
    required this.todayRevenue,
    required this.totalBookings,
    required this.activeQueue,
    required this.avgRating,
    required this.pendingActions,
    required this.revenueChange,
    required this.bookingsChange,
  });

  @override
  List<Object?> get props => [
        todayRevenue,
        totalBookings,
        activeQueue,
        avgRating,
        pendingActions,
        revenueChange,
        bookingsChange,
      ];
}
