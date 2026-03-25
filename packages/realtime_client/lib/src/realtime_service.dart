import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum ConnectionStatus { disconnected, connecting, connected, error }

class RealtimeService {
  RealtimeService({required String serverUrl, required String accessToken})
      : _serverUrl = serverUrl,
        _accessToken = accessToken;

  final String _serverUrl;
  final String _accessToken;

  io.Socket? _socket;

  final _connectionStatus =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected);

  Stream<ConnectionStatus> get connectionStatus => _connectionStatus.stream;
  ConnectionStatus get currentStatus => _connectionStatus.value;

  void connect() {
    if (_socket != null && _socket!.connected) return;

    _connectionStatus.add(ConnectionStatus.connecting);

    _socket = io.io(
      _serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': _accessToken})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(5)
          .build(),
    );

    _socket!
      ..onConnect((_) {
        debugPrint('[Realtime] Connected');
        _connectionStatus.add(ConnectionStatus.connected);
      })
      ..onDisconnect((_) {
        debugPrint('[Realtime] Disconnected');
        _connectionStatus.add(ConnectionStatus.disconnected);
      })
      ..onConnectError((data) {
        debugPrint('[Realtime] Connection error: $data');
        _connectionStatus.add(ConnectionStatus.error);
      });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _connectionStatus.add(ConnectionStatus.disconnected);
  }

  void emit(String event, dynamic data) {
    if (_socket?.connected == true) {
      _socket!.emit(event, data);
    } else {
      debugPrint('[Realtime] Cannot emit — not connected');
    }
  }

  Stream<T> on<T>(String event, T Function(dynamic data) parser) {
    final controller = StreamController<T>.broadcast();
    _socket?.on(event, (data) {
      try {
        controller.add(parser(data));
      } catch (e) {
        controller.addError(e);
      }
    });
    return controller.stream;
  }

  void off(String event) => _socket?.off(event);

  void dispose() {
    disconnect();
    _connectionStatus.close();
  }
}
