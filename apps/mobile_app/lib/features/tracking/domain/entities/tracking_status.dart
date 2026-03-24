/// Enum representing possible tracking session statuses.
enum TrackingStatus {
  /// Session has not been started yet.
  notStarted,
  /// Staff member is travelling to the customer location.
  staffEnRoute,
  /// Staff member has arrived at the customer location.
  staffArrived,
  /// Service is currently in progress.
  serviceInProgress,
  /// Session has been completed.
  completed,
}
