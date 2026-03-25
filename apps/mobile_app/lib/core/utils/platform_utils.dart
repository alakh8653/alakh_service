/// Platform detection helpers.
library platform_utils;

import 'dart:io';

import 'package:flutter/foundation.dart';

/// Provides platform-detection utilities that centralise `dart:io` and
/// `flutter/foundation.dart` checks.
abstract final class PlatformUtils {
  PlatformUtils._();

  // ── OS detection ──────────────────────────────────────────────────────────

  /// `true` when running on Android.
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// `true` when running on iOS.
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// `true` when running on macOS.
  static bool get isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// `true` when running on Windows.
  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// `true` when running on Linux.
  static bool get isLinux =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// `true` when running as a web app.
  static bool get isWeb => kIsWeb;

  /// `true` when running on a mobile platform (Android or iOS).
  static bool get isMobile => isAndroid || isIOS;

  /// `true` when running on a desktop platform (macOS, Windows, Linux).
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  // ── Build mode ────────────────────────────────────────────────────────────

  /// `true` in debug mode (assertions enabled).
  static bool get isDebug => kDebugMode;

  /// `true` in release mode (full optimisations, no assertions).
  static bool get isRelease => kReleaseMode;

  /// `true` in profile mode (profiling instrumentation enabled).
  static bool get isProfile => kProfileMode;

  // ── Device info (basic) ───────────────────────────────────────────────────

  /// Returns the operating system version string.
  ///
  /// Returns `'web'` when [isWeb] is true.
  static String get osVersion {
    if (isWeb) return 'web';
    return Platform.operatingSystemVersion;
  }

  /// Returns the operating system name (e.g. `'android'`, `'ios'`).
  static String get osName {
    if (isWeb) return 'web';
    return Platform.operatingSystem;
  }

  // ── Screen type helpers ───────────────────────────────────────────────────

  /// Returns a human-readable platform label for analytics / logging.
  static String get label {
    if (isWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (isMacOS) return 'macos';
    if (isWindows) return 'windows';
    if (isLinux) return 'linux';
    return 'unknown';
  }
}
