/// Network connectivity monitoring service.
library;

import 'dart:async';

// TODO: Add `connectivity_plus` package to pubspec.yaml.

/// The type of network connection available.
enum ConnectionType {
  none,
  wifi,
  mobile,
  ethernet,
  bluetooth,
  other,
}

/// Monitors network connectivity state in real time.
///
/// ### Usage:
/// ```dart
/// final service = ConnectivityService.instance;
/// await service.init();
/// print(service.isConnected);
/// service.onConnectionChanged.listen((type) { ... });
/// ```
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final StreamController<ConnectionType> _controller =
      StreamController<ConnectionType>.broadcast();

  ConnectionType _currentType = ConnectionType.none;

  /// The most recently detected connection type.
  ConnectionType get currentType => _currentType;

  /// `true` when the device has any form of network access.
  bool get isConnected => _currentType != ConnectionType.none;

  /// Stream of connection type changes.
  Stream<ConnectionType> get onConnectionChanged => _controller.stream;

  /// Initialises the service and begins monitoring connectivity.
  Future<void> init() async {
    // TODO:
    // final connectivity = Connectivity();
    // _subscription = connectivity.onConnectivityChanged.listen((results) {
    //   _currentType = _map(results.first);
    //   _controller.add(_currentType);
    // });
    // final initial = await connectivity.checkConnectivity();
    // _currentType = _map(initial.first);
  }

  // TODO:
  // ConnectionType _map(ConnectivityResult result) {
  //   switch (result) {
  //     case ConnectivityResult.wifi: return ConnectionType.wifi;
  //     case ConnectivityResult.mobile: return ConnectionType.mobile;
  //     case ConnectivityResult.ethernet: return ConnectionType.ethernet;
  //     case ConnectivityResult.bluetooth: return ConnectionType.bluetooth;
  //     case ConnectivityResult.none: return ConnectionType.none;
  //     default: return ConnectionType.other;
  //   }
  // }

  /// Disposes the stream controller and cancels subscriptions.
  void dispose() {
    _controller.close();
    // _subscription?.cancel();
  }
}
