import 'package:equatable/equatable.dart';

/// Abstract interface for OTP send and verification operations.
///
/// Implement this interface against your backend's OTP API endpoints.
abstract class OtpService {
  /// Sends an OTP to the given [phone] number or [email] address.
  ///
  /// Exactly one of [phone] or [email] must be non-null.
  /// Returns an [OtpSendResult] describing the outcome.
  Future<OtpSendResult> sendOtp({String? phone, String? email});

  /// Verifies [code] against the OTP sent to [phone] or [email].
  ///
  /// Returns `true` if the code is correct and within its validity window.
  /// Throws [OtpExpiredException], [OtpInvalidException], or
  /// [OtpLimitExceededException] on failure.
  Future<bool> verifyOtp({
    required String code,
    String? phone,
    String? email,
  });

  /// Resends the OTP to [phone] or [email].
  ///
  /// Implementations should enforce a cooldown period; if the cooldown has not
  /// elapsed, throw [OtpLimitExceededException].
  Future<OtpSendResult> resendOtp({String? phone, String? email});
}

/// The result of a successful OTP send or resend request.
class OtpSendResult extends Equatable {
  /// Whether the OTP was dispatched successfully.
  final bool success;

  /// An optional human-readable status message from the backend.
  final String? message;

  /// Seconds until the OTP expires, if provided by the backend.
  final int? expiresInSeconds;

  /// Minimum seconds the client should wait before requesting a resend.
  final int? resendAfterSeconds;

  const OtpSendResult({
    required this.success,
    this.message,
    this.expiresInSeconds,
    this.resendAfterSeconds,
  });

  @override
  List<Object?> get props =>
      [success, message, expiresInSeconds, resendAfterSeconds];
}
