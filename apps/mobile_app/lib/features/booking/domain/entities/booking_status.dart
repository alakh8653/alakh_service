/// Represents the lifecycle states of a booking.
enum BookingStatus {
  /// Booking created but not yet confirmed by the shop.
  pending,

  /// Shop has confirmed the booking.
  confirmed,

  /// Service is currently being performed.
  inProgress,

  /// Service has been completed successfully.
  completed,

  /// Booking was cancelled by the user or shop.
  cancelled,

  /// Customer did not show up for the appointment.
  noShow,
}
