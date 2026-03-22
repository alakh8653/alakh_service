/// Mixin for observing app lifecycle events inside a [State].
library;

import 'package:flutter/widgets.dart';

/// Attach to a [State] to receive foreground / background lifecycle callbacks.
///
/// ### Usage:
/// ```dart
/// class _MyState extends State<MyScreen> with LifecycleMixin {
///   @override
///   void onForeground() => _startRefreshTimer();
///
///   @override
///   void onBackground() => _cancelRefreshTimer();
/// }
/// ```
mixin LifecycleMixin<T extends StatefulWidget> on State<T>
    implements WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // WidgetsBindingObserver
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onForeground();
      case AppLifecycleState.paused:
        onBackground();
      case AppLifecycleState.inactive:
        onInactive();
      case AppLifecycleState.detached:
        onDetached();
      case AppLifecycleState.hidden:
        onHidden();
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {}
  @override
  void didChangeMetrics() {}
  @override
  void didChangeTextScaleFactor() {}
  @override
  void didChangePlatformBrightness() {}
  @override
  void didChangeAccessibilityFeatures() {}
  @override
  void didHaveMemoryPressure() {}
  @override
  Future<bool> didPopRoute() async => false;
  @override
  Future<bool> didPushRoute(String route) async => false;
  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async =>
      false;
  @override
  void didRequestAppExit() {}

  // ---------------------------------------------------------------------------
  // Override hooks
  // ---------------------------------------------------------------------------

  /// Called when the app comes to the foreground (resumed).
  void onForeground() {}

  /// Called when the app goes to the background (paused).
  void onBackground() {}

  /// Called when the app becomes inactive (e.g. phone call, control centre).
  void onInactive() {}

  /// Called when the app is detached from the UI (about to be destroyed).
  void onDetached() {}

  /// Called when the app is hidden (e.g. on desktop platforms).
  void onHidden() {}
}
