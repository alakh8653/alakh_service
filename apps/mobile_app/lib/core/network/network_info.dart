/// Network connectivity checker service.
///
/// Abstracts platform-specific connectivity APIs behind a clean interface so
/// feature code can ask "am I online?" without depending on any particular
/// plugin directly.
///
/// Add `connectivity_plus` to your `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   connectivity_plus: ^6.0.0
/// ```
library network_info;

// TODO: Uncomment when connectivity_plus is added to pubspec.yaml
// import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for checking network connectivity.
abstract class NetworkInfo {
  /// Returns `true` if the device currently has an internet connection.
  Future<bool> get isConnected;

  /// Stream that emits `true`/`false` whenever connectivity changes.
  Stream<bool> get onConnectivityChanged;
}

/// [NetworkInfo] implementation backed by the `connectivity_plus` package.
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl();
  // TODO: inject Connectivity() from connectivity_plus

  @override
  Future<bool> get isConnected async {
    // TODO: Replace with real connectivity check:
    // final result = await Connectivity().checkConnectivity();
    // return result != ConnectivityResult.none;
    return true; // optimistic default during development
  }

  @override
  Stream<bool> get onConnectivityChanged async* {
    // TODO: Replace with real stream:
    // yield* Connectivity()
    //     .onConnectivityChanged
    //     .map((r) => r != ConnectivityResult.none);
    yield true;
  }
}

/// Lightweight in-memory stub for testing and offline development.
class MockNetworkInfo implements NetworkInfo {
  MockNetworkInfo({this.isOnline = true});

  /// Controls what [isConnected] returns.
  bool isOnline;

  @override
  Future<bool> get isConnected async => isOnline;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(isOnline);
}
