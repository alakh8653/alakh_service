/// Biometric authentication service.
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   local_auth: ^2.2.0
/// ```
library biometric_service;

import '../utils/logger.dart';

// TODO: Uncomment when local_auth is added:
// import 'package:local_auth/local_auth.dart';
// import 'package:local_auth/error_codes.dart' as auth_error;

/// The outcome of a biometric authentication attempt.
enum BiometricResult {
  /// Authentication succeeded.
  success,

  /// Authentication failed (wrong fingerprint / face).
  failed,

  /// Biometrics are not available on this device.
  notAvailable,

  /// Biometrics are not enrolled.
  notEnrolled,

  /// The user cancelled the authentication dialog.
  cancelled,

  /// Too many failed attempts – biometrics are locked out.
  lockedOut,

  /// An unexpected error occurred.
  error,
}

/// Abstract interface for biometric authentication.
abstract class BiometricService {
  /// Returns `true` if biometric authentication is available and enrolled.
  Future<bool> isAvailable();

  /// Returns a list of enrolled biometric types on this device.
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Prompts the user for biometric authentication.
  ///
  /// [reason] is the localised string shown in the system dialog.
  Future<BiometricResult> authenticate({
    String reason = 'Authenticate to continue',
    bool biometricOnly = true,
  });
}

/// Biometric type enum (mirrors `local_auth.BiometricType`).
enum BiometricType {
  fingerprint,
  face,
  iris,
  weak,
  strong,
}

/// [BiometricService] backed by the `local_auth` package.
class LocalAuthBiometricService implements BiometricService {
  LocalAuthBiometricService();

  // TODO: final _auth = LocalAuthentication();
  final _log = AppLogger('BiometricService');

  @override
  Future<bool> isAvailable() async {
    // TODO:
    // try {
    //   final canCheck = await _auth.canCheckBiometrics;
    //   final isSupported = await _auth.isDeviceSupported();
    //   if (!canCheck || !isSupported) return false;
    //   final biometrics = await _auth.getAvailableBiometrics();
    //   return biometrics.isNotEmpty;
    // } catch (_) {
    //   return false;
    // }
    _log.d('isAvailable – stub returning false');
    return false;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    // TODO:
    // final types = await _auth.getAvailableBiometrics();
    // return types.map(_fromPackageType).toList();
    return [];
  }

  @override
  Future<BiometricResult> authenticate({
    String reason = 'Authenticate to continue',
    bool biometricOnly = true,
  }) async {
    // TODO:
    // try {
    //   final success = await _auth.authenticate(
    //     localizedReason: reason,
    //     options: AuthenticationOptions(biometricOnly: biometricOnly),
    //   );
    //   return success ? BiometricResult.success : BiometricResult.failed;
    // } on PlatformException catch (e) {
    //   return switch (e.code) {
    //     auth_error.notAvailable    => BiometricResult.notAvailable,
    //     auth_error.notEnrolled     => BiometricResult.notEnrolled,
    //     auth_error.lockedOut ||
    //     auth_error.permanentlyLockedOut => BiometricResult.lockedOut,
    //     _ => BiometricResult.error,
    //   };
    // }
    _log.d('authenticate – stub returning notAvailable');
    return BiometricResult.notAvailable;
  }

  // TODO: BiometricType _fromPackageType(la.BiometricType t) => switch (t) {
  //   la.BiometricType.fingerprint => BiometricType.fingerprint,
  //   la.BiometricType.face        => BiometricType.face,
  //   la.BiometricType.iris        => BiometricType.iris,
  //   la.BiometricType.weak        => BiometricType.weak,
  //   la.BiometricType.strong      => BiometricType.strong,
  // };
}
