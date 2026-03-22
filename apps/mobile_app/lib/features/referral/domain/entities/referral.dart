import 'package:equatable/equatable.dart';

import 'referral_status.dart';

/// Domain entity representing a single referral relationship between a
/// [referrer] (the user who shared their code) and a [referee] (the invited
/// user).
class Referral extends Equatable {
  /// Unique identifier for this referral record.
  final String id;

  /// Identifier of the user who issued the referral.
  final String referrerId;

  /// Identifier of the user who was referred.
  final String refereeId;

  /// Display name of the referred user.
  final String refereeName;

  /// The referral code that was used to establish this relationship.
  final String code;

  /// Current lifecycle status of the referral.
  final ReferralStatus status;

  /// Monetary reward amount associated with this referral (in [currency] units).
  final double rewardAmount;

  /// ISO 4217 currency code, e.g. `"INR"`.
  final String currency;

  /// When the referral record was created.
  final DateTime createdAt;

  /// When the referral reached [ReferralStatus.firstBookingCompleted], or
  /// `null` if not yet completed.
  final DateTime? completedAt;

  /// Creates a [Referral] entity.
  const Referral({
    required this.id,
    required this.referrerId,
    required this.refereeId,
    required this.refereeName,
    required this.code,
    required this.status,
    required this.rewardAmount,
    required this.currency,
    required this.createdAt,
    this.completedAt,
  });

  /// Returns `true` if the referral has an associated completed timestamp.
  bool get isCompleted => completedAt != null;

  @override
  List<Object?> get props => [
        id,
        referrerId,
        refereeId,
        refereeName,
        code,
        status,
        rewardAmount,
        currency,
        createdAt,
        completedAt,
      ];

  @override
  String toString() =>
      'Referral(id: $id, referee: $refereeName, status: ${status.label})';
}
