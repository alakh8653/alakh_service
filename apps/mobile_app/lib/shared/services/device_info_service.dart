/// Device information retrieval service.
library;

// TODO: Add `device_info_plus` and `package_info_plus` packages to pubspec.yaml.

/// Snapshot of the current device and app information.
class DeviceInfo {
  const DeviceInfo({
    required this.platform,
    required this.model,
    required this.osVersion,
    required this.appVersion,
    required this.appBuildNumber,
    required this.appPackageName,
    this.deviceId,
    this.manufacturer,
    this.isPhysicalDevice = true,
  });

  /// Platform string: `"android"` or `"ios"`.
  final String platform;

  /// Device model name (e.g. `"Pixel 7"`, `"iPhone 14"`).
  final String model;

  /// Operating system version string.
  final String osVersion;

  /// App version string (e.g. `"1.2.3"`).
  final String appVersion;

  /// Build number / version code.
  final String appBuildNumber;

  /// App package / bundle identifier.
  final String appPackageName;

  /// Unique device identifier (may be null due to OS restrictions).
  final String? deviceId;

  /// Device manufacturer (Android only).
  final String? manufacturer;

  /// Whether the app is running on a physical device (as opposed to emulator).
  final bool isPhysicalDevice;

  @override
  String toString() =>
      'DeviceInfo(platform: $platform, model: $model, '
      'os: $osVersion, app: $appVersion+$appBuildNumber)';
}

/// Retrieves device and app metadata.
///
/// ### Usage:
/// ```dart
/// final info = await DeviceInfoService.instance.getDeviceInfo();
/// print(info.platform);
/// ```
class DeviceInfoService {
  DeviceInfoService._();
  static final DeviceInfoService instance = DeviceInfoService._();

  DeviceInfo? _cached;

  /// Returns [DeviceInfo], fetching from the device if not yet cached.
  Future<DeviceInfo> getDeviceInfo() async {
    if (_cached != null) return _cached!;

    // TODO:
    // final deviceInfo = DeviceInfoPlugin();
    // final packageInfo = await PackageInfo.fromPlatform();
    //
    // if (Platform.isAndroid) {
    //   final android = await deviceInfo.androidInfo;
    //   _cached = DeviceInfo(
    //     platform: 'android',
    //     model: android.model,
    //     osVersion: android.version.release,
    //     appVersion: packageInfo.version,
    //     appBuildNumber: packageInfo.buildNumber,
    //     appPackageName: packageInfo.packageName,
    //     deviceId: android.id,
    //     manufacturer: android.manufacturer,
    //     isPhysicalDevice: android.isPhysicalDevice,
    //   );
    // } else if (Platform.isIOS) {
    //   final ios = await deviceInfo.iosInfo;
    //   _cached = DeviceInfo(
    //     platform: 'ios',
    //     model: ios.model,
    //     osVersion: ios.systemVersion,
    //     appVersion: packageInfo.version,
    //     appBuildNumber: packageInfo.buildNumber,
    //     appPackageName: packageInfo.packageName,
    //     deviceId: ios.identifierForVendor,
    //     isPhysicalDevice: ios.isPhysicalDevice,
    //   );
    // }
    //
    // return _cached!;

    // Stub response until plugin is integrated.
    _cached = const DeviceInfo(
      platform: 'unknown',
      model: 'unknown',
      osVersion: 'unknown',
      appVersion: '0.0.0',
      appBuildNumber: '0',
      appPackageName: 'com.example.app',
    );
    return _cached!;
  }

  /// Clears the cached [DeviceInfo] (useful in tests).
  void clearCache() => _cached = null;
}
