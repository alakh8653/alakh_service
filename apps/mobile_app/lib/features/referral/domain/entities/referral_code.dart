import 'package:equatable/equatable.dart';

/// Domain entity representing the unique referral code belonging to a user.
///
/// The [deepLink] can be shared directly so that new users are directed to the
/// app with the code pre-filled.
class ReferralCode extends Equatable {
  /// The short alphanumeric referral code, e.g. `"ALAKH20"`.
  final String code;

  /// A fully-qualified deep-link URL that opens the app (or the web landing
  /// page) with this referral code pre-applied.
  final String deepLink;

  /// When this code stops accepting new referrals.  `null` means no expiry.
  final DateTime? expiresAt;

  /// Maximum number of times this code can be used. `null` means unlimited.
  final int? maxUses;

  /// How many uses remain before [maxUses] is reached.  `null` when [maxUses]
  /// is `null`.
  final int? usesRemaining;

  /// Creates a [ReferralCode] entity.
  const ReferralCode({
    required this.code,
    required this.deepLink,
    this.expiresAt,
    this.maxUses,
    this.usesRemaining,
  });

  /// Returns `true` when the code has not yet expired and still has available
  /// uses (if a limit is set).
  bool get isActive {
    final notExpired =
        expiresAt == null || expiresAt!.isAfter(DateTime.now());
    final hasUses = maxUses == null || (usesRemaining ?? 0) > 0;
    return notExpired && hasUses;
  }

  /// Percentage of allowed uses consumed, between `0.0` and `1.0`.
  /// Returns `null` when there is no [maxUses] limit.
  double? get usageRatio {
    if (maxUses == null || maxUses == 0) return null;
    final used = maxUses! - (usesRemaining ?? 0);
    return used / maxUses!;
  }

  @override
  List<Object?> get props =>
      [code, deepLink, expiresAt, maxUses, usesRemaining];

  @override
  String toString() => 'ReferralCode(code: $code, active: $isActive)';
}
