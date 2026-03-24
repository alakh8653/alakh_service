import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'realtime_events.dart';

/// Manages the Socket.IO connection lifecycle and event subscriptions.
class RealtimeService {
  RealtimeService({required String serverUrl, String? Function()? getToken})
      : _serverUrl = serverUrl,
        _getToken = getToken;

  final String _serverUrl;
  final String? Function()? _getToken;

  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// Establishes the Socket.IO connection.
  void connect() {
    _socket = io.io(
      _serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': _getToken?.call() ?? ''})
          .build(),
    );

    _socket!
      ..onConnect((_) => debugPrint('[Realtime] Connected'))
      ..onDisconnect((_) => debugPrint('[Realtime] Disconnected'))
      ..onConnectError((e) => debugPrint('[Realtime] Connection error: $e'));
  }

  /// Disconnects the Socket.IO connection.
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Emits an event with optional [data] to the server.
  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  /// Subscribes to [event] and returns a stream of incoming data.
  Stream<dynamic> on(String event) {
    final controller = StreamController<dynamic>.broadcast();
    _socket?.on(event, controller.add);
    return controller.stream;
  }

  /// Removes the listener for [event].
  void off(String event) {
    _socket?.off(event);
  }

  // ── Convenience helpers ────────────────────────────────────────────────────

  Stream<dynamic> get queueUpdates => on(RealtimeEvents.queueUpdate);
  Stream<dynamic> get dispatchUpdates => on(RealtimeEvents.dispatchUpdate);
  Stream<dynamic> get chatMessages => on(RealtimeEvents.chatMessage);
  Stream<dynamic> get locationUpdates => on(RealtimeEvents.locationUpdate);
}
