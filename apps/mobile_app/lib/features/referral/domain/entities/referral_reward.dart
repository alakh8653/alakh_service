import 'package:equatable/equatable.dart';

/// The type of benefit granted as a referral reward.
enum RewardType {
  /// Cashback credited to the user's wallet or payment method.
  cashback,

  /// In-app credit usable on future bookings.
  credit,

  /// Percentage or flat discount applied to a specific booking.
  discount,
}

/// Extension helpers on [RewardType].
extension RewardTypeX on RewardType {
  /// Human-readable label for display in the UI.
  String get label {
    switch (this) {
      case RewardType.cashback:
        return 'Cashback';
      case RewardType.credit:
        return 'Credit';
      case RewardType.discount:
        return 'Discount';
    }
  }

  /// Parses the raw API string into a [RewardType].
  static RewardType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'credit':
        return RewardType.credit;
      case 'discount':
        return RewardType.discount;
      case 'cashback':
      default:
        return RewardType.cashback;
    }
  }

  /// Serialises this type to the raw string expected by the API.
  String get apiValue => name;
}

/// The processing status of a referral reward.
enum RewardStatus {
  /// Reward has been earned but not yet claimed.
  available,

  /// Claim is being processed.
  processing,

  /// Reward has been successfully disbursed.
  claimed,

  /// The reward window has closed without being claimed.
  expired,
}

/// Extension helpers on [RewardStatus].
extension RewardStatusX on RewardStatus {
  /// Human-readable label.
  String get label {
    switch (this) {
      case RewardStatus.available:
        return 'Available';
      case RewardStatus.processing:
        return 'Processing';
      case RewardStatus.claimed:
        return 'Claimed';
      case RewardStatus.expired:
        return 'Expired';
    }
  }

  /// Parses the raw API string.
  static RewardStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'processing':
        return RewardStatus.processing;
      case 'claimed':
        return RewardStatus.claimed;
      case 'expired':
        return RewardStatus.expired;
      case 'available':
      default:
        return RewardStatus.available;
    }
  }

  /// Serialises to the raw API string.
  String get apiValue => name;
}

/// Domain entity representing a single reward earned through the referral
/// programme.
class ReferralReward extends Equatable {
  /// Unique reward identifier.
  final String id;

  /// Category of reward granted.
  final RewardType type;

  /// Monetary value of the reward (in [currency] units).
  final double amount;

  /// ISO 4217 currency code, e.g. `"INR"`.
  final String currency;

  /// Current processing status.
  final RewardStatus status;

  /// When the reward was claimed, or `null` if not yet claimed.
  final DateTime? claimedAt;

  /// Optional expiry date after which the reward can no longer be claimed.
  final DateTime? expiresAt;

  /// Creates a [ReferralReward] entity.
  const ReferralReward({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.claimedAt,
    this.expiresAt,
  });

  /// Whether this reward can currently be claimed by the user.
  bool get isClaimed => status == RewardStatus.claimed;

  /// Whether this reward is still available for claiming.
  bool get isAvailable => status == RewardStatus.available;

  @override
  List<Object?> get props =>
      [id, type, amount, currency, status, claimedAt, expiresAt];

  @override
  String toString() =>
      'ReferralReward(id: $id, type: ${type.label}, amount: $amount $currency, status: ${status.label})';
}
