/// Accessibility settings manager.
///
/// Reads platform accessibility settings and exposes them as reactive streams
/// so the UI can adapt (larger fonts, high contrast, screen reader hints).
library accessibility_service;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../utils/logger.dart';

/// Manages accessibility settings derived from the device's platform settings.
///
/// Attach this service to [WidgetsBindingObserver] in your app widget to
/// receive live updates when the user changes accessibility settings.
class AccessibilityService with WidgetsBindingObserver {
  AccessibilityService();

  final _log = AppLogger('AccessibilityService');

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Attaches this service to [WidgetsBinding] to receive setting changes.
  ///
  /// Call once at app startup, after [WidgetsFlutterBinding.ensureInitialized].
  void attach() {
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _log.i('AccessibilityService attached');
  }

  /// Detaches from [WidgetsBinding]. Call in [dispose].
  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  // ── State ─────────────────────────────────────────────────────────────────

  /// Current device text-scale factor (reflects the user's font size setting).
  double get textScaleFactor =>
      WidgetsBinding.instance.platformDispatcher.textScaleFactor;

  /// Whether the user has enabled bold text (iOS).
  bool get boldTextEnabled =>
      WidgetsBinding.instance.platformDispatcher.boldText;

  /// Whether Reduce Motion is enabled on the device.
  bool get reduceMotion =>
      WidgetsBinding.instance.platformDispatcher.disableAnimations;

  /// Whether the screen reader (TalkBack / VoiceOver) is active.
  bool get isScreenReaderActive =>
      WidgetsBinding.instance.accessibilityFeatures.accessibleNavigation;

  /// Whether high-contrast mode is active.
  bool get highContrastEnabled =>
      WidgetsBinding.instance.accessibilityFeatures.highContrast;

  /// Whether inverted-colours mode is active.
  bool get invertColorsEnabled =>
      WidgetsBinding.instance.accessibilityFeatures.invertColors;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Whether the text scale factor is above the "large text" threshold (1.3×).
  bool get isLargeText => textScaleFactor >= 1.3;

  /// Whether the text scale factor is above the "extra-large text" threshold (1.6×).
  bool get isExtraLargeText => textScaleFactor >= 1.6;

  /// Recommended animation duration – reduced when [reduceMotion] is active.
  Duration get animationDuration =>
      reduceMotion ? Duration.zero : const Duration(milliseconds: 250);

  // ── WidgetsBindingObserver ────────────────────────────────────────────────

  @override
  void didChangeAccessibilityFeatures() {
    _log.d('Accessibility features changed');
    _refresh();
  }

  @override
  void didChangeTextScaleFactor() {
    _log.d('Text scale factor changed: $textScaleFactor');
    _refresh();
  }

  void _refresh() {
    _log.d(
      'A11y state – '
      'textScale: $textScaleFactor, '
      'boldText: $boldTextEnabled, '
      'reduceMotion: $reduceMotion, '
      'screenReader: $isScreenReaderActive, '
      'highContrast: $highContrastEnabled',
    );
  }

  // ── Static builder helpers ────────────────────────────────────────────────

  /// Returns a [MediaQuery] clamped so font scaling never exceeds [maxScale].
  ///
  /// Wrap screen content to prevent extreme text overflow:
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return AccessibilityService.clampTextScale(
  ///     context: context,
  ///     maxScale: 1.4,
  ///     child: MyScreen(),
  ///   );
  /// }
  /// ```
  static Widget clampTextScale({
    required BuildContext context,
    required Widget child,
    double maxScale = 1.4,
    double minScale = 0.8,
  }) {
    final mq = MediaQuery.of(context);
    final clamped = mq.textScaler.scale(1.0).clamp(minScale, maxScale);
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(clamped)),
      child: child,
    );
  }
}
