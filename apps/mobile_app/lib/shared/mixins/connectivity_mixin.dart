/// Mixin to observe network connectivity changes inside a [State].
library;

import 'package:flutter/widgets.dart';

// TODO: Add `connectivity_plus` package to pubspec.yaml and replace the stub
// below with real connectivity monitoring.
//
// import 'package:connectivity_plus/connectivity_plus.dart';

/// Attach to a [State] to receive connectivity-change callbacks.
///
/// Override [onConnectivityChanged] to react to network status updates.
///
/// ### Usage:
/// ```dart
/// class _HomeState extends State<HomeScreen> with ConnectivityMixin {
///   @override
///   void onConnectivityChanged(bool isConnected) {
///     if (!isConnected) showOfflineBanner();
///   }
/// }
/// ```
mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  bool _isConnected = true;

  /// Whether the device currently has network access.
  bool get isConnected => _isConnected;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Override hook
  // ---------------------------------------------------------------------------

  /// Called whenever connectivity state changes.
  ///
  /// [isConnected] is `true` when the device is back online.
  void onConnectivityChanged(bool isConnected) {}

  // ---------------------------------------------------------------------------
  // Internal — stub implementation
  // ---------------------------------------------------------------------------

  void _startListening() {
    // TODO: Subscribe to Connectivity().onConnectivityChanged stream.
    // Example:
    // _subscription = Connectivity()
    //     .onConnectivityChanged
    //     .listen((result) {
    //   final connected = result != ConnectivityResult.none;
    //   if (connected != _isConnected) {
    //     setState(() => _isConnected = connected);
    //     onConnectivityChanged(connected);
    //   }
    // });
  }

  void _stopListening() {
    // TODO: Cancel the subscription.
    // _subscription?.cancel();
  }
}
