/// Permission status models and enums.
library permission_status;

/// The status of a runtime permission.
enum AppPermissionStatus {
  /// The permission has not been requested yet.
  notDetermined,

  /// The user explicitly granted the permission.
  granted,

  /// The user denied the permission (can be re-requested).
  denied,

  /// The user permanently denied the permission (must open Settings).
  permanentlyDenied,

  /// The permission is restricted by the OS (e.g. parental controls).
  restricted,

  /// The permission requires showing a rationale dialog first.
  needsRationale,
}

/// Extension with convenience checks on [AppPermissionStatus].
extension AppPermissionStatusX on AppPermissionStatus {
  /// `true` when the permission is fully granted.
  bool get isGranted => this == AppPermissionStatus.granted;

  /// `true` when the user can still be asked for the permission.
  bool get canRequest =>
      this == AppPermissionStatus.notDetermined ||
      this == AppPermissionStatus.denied ||
      this == AppPermissionStatus.needsRationale;

  /// `true` when the user must be sent to OS Settings to grant.
  bool get requiresSettings =>
      this == AppPermissionStatus.permanentlyDenied ||
      this == AppPermissionStatus.restricted;
}

/// Enum of all permissions used by the app.
enum AppPermission {
  /// Camera access for photo capture / QR scanning.
  camera,

  /// Microphone access for voice calls.
  microphone,

  /// Fine (GPS) location for nearby services.
  locationWhenInUse,

  /// Background location for job tracking.
  locationAlways,

  /// Push notifications.
  notifications,

  /// Photo library / gallery access.
  photos,

  /// Contacts access (for referral features).
  contacts,

  /// Biometrics / Face ID.
  biometrics,

  /// Bluetooth (for proximity-based features).
  bluetooth,
}

/// Result returned by [PermissionHandler.request] and [PermissionHandler.check].
class PermissionResult {
  const PermissionResult({
    required this.permission,
    required this.status,
  });

  final AppPermission permission;
  final AppPermissionStatus status;

  bool get isGranted => status.isGranted;

  @override
  String toString() =>
      'PermissionResult(permission: $permission, status: $status)';
}
