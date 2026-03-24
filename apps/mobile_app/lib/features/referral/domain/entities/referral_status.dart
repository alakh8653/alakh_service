/// Represents the lifecycle stage of a referral.
enum ReferralStatus {
  /// Referee has been invited but has not yet registered.
  pending,

  /// Referee has completed registration.
  registered,

  /// Referee has completed their first booking.
  firstBookingCompleted,

  /// The reward for this referral has been claimed by the referrer.
  rewardClaimed,

  /// The referral link or code has expired before the referee completed the required actions.
  expired,
}

/// Extension helpers on [ReferralStatus].
extension ReferralStatusX on ReferralStatus {
  /// Human-readable label for display in the UI.
  String get label {
    switch (this) {
      case ReferralStatus.pending:
        return 'Pending';
      case ReferralStatus.registered:
        return 'Registered';
      case ReferralStatus.firstBookingCompleted:
        return 'Booking Completed';
      case ReferralStatus.rewardClaimed:
        return 'Reward Claimed';
      case ReferralStatus.expired:
        return 'Expired';
    }
  }

  /// Returns `true` if the referral is in a terminal state (no further action possible).
  bool get isTerminal =>
      this == ReferralStatus.rewardClaimed || this == ReferralStatus.expired;

  /// Parses a raw string value from the API into a [ReferralStatus].
  static ReferralStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'registered':
        return ReferralStatus.registered;
      case 'first_booking_completed':
        return ReferralStatus.firstBookingCompleted;
      case 'reward_claimed':
        return ReferralStatus.rewardClaimed;
      case 'expired':
        return ReferralStatus.expired;
      case 'pending':
      default:
        return ReferralStatus.pending;
    }
  }

  /// Serialises this status to the raw string expected by the API.
  String get apiValue {
    switch (this) {
      case ReferralStatus.pending:
        return 'pending';
      case ReferralStatus.registered:
        return 'registered';
      case ReferralStatus.firstBookingCompleted:
        return 'first_booking_completed';
      case ReferralStatus.rewardClaimed:
        return 'reward_claimed';
      case ReferralStatus.expired:
        return 'expired';
    }
  }
}
