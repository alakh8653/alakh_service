import 'package:equatable/equatable.dart';

/// Connection status for the real-time WebSocket client.
enum RealtimeConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  disconnecting,
  error,
}

/// Represents the current connection state of the WebSocket client.
class RealtimeConnection extends Equatable {
  final RealtimeConnectionStatus status;
  final String? errorMessage;
  final int reconnectAttempt;
  final DateTime? connectedAt;
  final DateTime? disconnectedAt;

  const RealtimeConnection({
    required this.status,
    this.errorMessage,
    this.reconnectAttempt = 0,
    this.connectedAt,
    this.disconnectedAt,
  });

  bool get isConnected => status == RealtimeConnectionStatus.connected;
  bool get isDisconnected =>
      status == RealtimeConnectionStatus.disconnected ||
      status == RealtimeConnectionStatus.error;
  bool get isReconnecting =>
      status == RealtimeConnectionStatus.reconnecting;
  bool get isConnecting =>
      status == RealtimeConnectionStatus.connecting;

  RealtimeConnection copyWith({
    RealtimeConnectionStatus? status,
    String? errorMessage,
    int? reconnectAttempt,
    DateTime? connectedAt,
    DateTime? disconnectedAt,
  }) {
    return RealtimeConnection(
      status: status ?? this.status,
      errorMessage: errorMessage,
      reconnectAttempt: reconnectAttempt ?? this.reconnectAttempt,
      connectedAt: connectedAt ?? this.connectedAt,
      disconnectedAt: disconnectedAt ?? this.disconnectedAt,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        reconnectAttempt,
        connectedAt,
        disconnectedAt,
      ];

  @override
  String toString() =>
      'RealtimeConnection(status: $status, attempt: $reconnectAttempt)';
}
