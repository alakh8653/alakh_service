/// Represents the current lifecycle state of a booking.
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow;

  /// Serializes this status to a JSON string.
  String toJson() => name;

  /// Deserializes a status from a JSON string.
  /// Falls back to [BookingStatus.pending] if the value is unrecognized.
  static BookingStatus fromJson(String value) => BookingStatus.values
      .firstWhere((e) => e.name == value, orElse: () => BookingStatus.pending);
}
