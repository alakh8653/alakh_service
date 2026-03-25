/// Enum representing possible dispatch job statuses.
enum DispatchStatus {
  pending,
  assigned,
  accepted,
  enRoute,
  arrived,
  inProgress,
  completed,
  cancelled,
}

/// Extension providing helper methods on [DispatchStatus].
extension DispatchStatusX on DispatchStatus {
  /// Returns true if the job is still active (not completed or cancelled).
  bool get isActive => this != DispatchStatus.completed && this != DispatchStatus.cancelled;

  /// Returns a human-readable label for this status.
  String get label {
    switch (this) {
      case DispatchStatus.pending: return 'Pending';
      case DispatchStatus.assigned: return 'Assigned';
      case DispatchStatus.accepted: return 'Accepted';
      case DispatchStatus.enRoute: return 'En Route';
      case DispatchStatus.arrived: return 'Arrived';
      case DispatchStatus.inProgress: return 'In Progress';
      case DispatchStatus.completed: return 'Completed';
      case DispatchStatus.cancelled: return 'Cancelled';
    }
  }

  /// Parses a JSON string to [DispatchStatus].
  static DispatchStatus fromString(String value) {
    return DispatchStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DispatchStatus.pending,
    );
  }
}
