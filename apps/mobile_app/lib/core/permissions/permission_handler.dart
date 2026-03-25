/// Runtime permission request and check service.
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   permission_handler: ^11.3.0
/// ```
library permission_handler;

import '../utils/logger.dart';
import 'permission_status.dart';

// TODO: Uncomment when permission_handler is added to pubspec.yaml:
// import 'package:permission_handler/permission_handler.dart' as ph;

/// Abstract interface for checking and requesting runtime permissions.
abstract class PermissionHandler {
  /// Checks the current status of [permission] without requesting it.
  Future<PermissionResult> check(AppPermission permission);

  /// Requests [permission] from the OS, showing the system dialog if needed.
  Future<PermissionResult> request(AppPermission permission);

  /// Requests multiple permissions at once.
  Future<List<PermissionResult>> requestAll(List<AppPermission> permissions);

  /// Opens the app's OS Settings page so the user can grant permissions.
  Future<bool> openSettings();
}

/// Default [PermissionHandler] backed by the `permission_handler` package.
class PermissionHandlerImpl implements PermissionHandler {
  PermissionHandlerImpl();

  final _log = AppLogger('PermissionHandler');

  @override
  Future<PermissionResult> check(AppPermission permission) async {
    _log.d('check: $permission');
    // TODO: Replace with real check:
    // final ph.Permission p = _toPackagePermission(permission);
    // final ph.PermissionStatus status = await p.status;
    // return PermissionResult(permission: permission, status: _fromPackageStatus(status));
    return PermissionResult(
      permission: permission,
      status: AppPermissionStatus.notDetermined,
    );
  }

  @override
  Future<PermissionResult> request(AppPermission permission) async {
    _log.d('request: $permission');
    // TODO: Replace with real request:
    // final ph.Permission p = _toPackagePermission(permission);
    // final ph.PermissionStatus status = await p.request();
    // return PermissionResult(permission: permission, status: _fromPackageStatus(status));
    return PermissionResult(
      permission: permission,
      status: AppPermissionStatus.granted,
    );
  }

  @override
  Future<List<PermissionResult>> requestAll(
    List<AppPermission> permissions,
  ) async {
    final results = <PermissionResult>[];
    for (final p in permissions) {
      results.add(await request(p));
    }
    return results;
  }

  @override
  Future<bool> openSettings() async {
    // TODO: return openAppSettings(); from permission_handler
    _log.i('openSettings called');
    return false;
  }

  // TODO: Mapping helpers
  // ph.Permission _toPackagePermission(AppPermission p) => switch (p) {
  //   AppPermission.camera => ph.Permission.camera,
  //   AppPermission.microphone => ph.Permission.microphone,
  //   AppPermission.locationWhenInUse => ph.Permission.locationWhenInUse,
  //   AppPermission.locationAlways => ph.Permission.locationAlways,
  //   AppPermission.notifications => ph.Permission.notification,
  //   AppPermission.photos => ph.Permission.photos,
  //   AppPermission.contacts => ph.Permission.contacts,
  //   AppPermission.biometrics => throw UnimplementedError(),
  //   AppPermission.bluetooth => ph.Permission.bluetooth,
  // };
  //
  // AppPermissionStatus _fromPackageStatus(ph.PermissionStatus s) => switch (s) {
  //   ph.PermissionStatus.granted => AppPermissionStatus.granted,
  //   ph.PermissionStatus.denied => AppPermissionStatus.denied,
  //   ph.PermissionStatus.permanentlyDenied => AppPermissionStatus.permanentlyDenied,
  //   ph.PermissionStatus.restricted => AppPermissionStatus.restricted,
  //   _ => AppPermissionStatus.notDetermined,
  // };
}
