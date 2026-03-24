/// Enum representing possible queue entry statuses.
///
/// - [waiting]: The entry is in the queue, waiting to be called.
/// - [called]: The customer has been called but has not yet checked in.
/// - [serving]: The customer is currently being served.
/// - [completed]: Service has been completed successfully.
/// - [cancelled]: The entry was cancelled by the customer or the shop.
/// - [noShow]: The customer did not respond when called.
enum QueueStatus { waiting, called, serving, completed, cancelled, noShow }

/// Extension providing human-readable labels for [QueueStatus].
extension QueueStatusLabel on QueueStatus {
  /// Returns a display-friendly label for the status.
  String get label {
    switch (this) {
      case QueueStatus.waiting:
        return 'Waiting';
      case QueueStatus.called:
        return 'Called';
      case QueueStatus.serving:
        return 'Serving';
      case QueueStatus.completed:
        return 'Completed';
      case QueueStatus.cancelled:
        return 'Cancelled';
      case QueueStatus.noShow:
        return 'No Show';
    }
  }

  /// Returns `true` when the entry is still active (not yet done or cancelled).
  bool get isActive =>
      this == QueueStatus.waiting ||
      this == QueueStatus.called ||
      this == QueueStatus.serving;
}
