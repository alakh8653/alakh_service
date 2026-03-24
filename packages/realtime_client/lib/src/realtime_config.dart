import 'package:equatable/equatable.dart';

/// Configuration for the real-time WebSocket client.
class RealtimeConfig extends Equatable {
  /// The WebSocket server URL.
  final String url;

  /// Delay between reconnect attempts.
  final Duration reconnectDelay;

  /// Maximum number of reconnect attempts. Use -1 for unlimited.
  final int maxReconnectAttempts;

  /// Interval at which heartbeat messages are sent.
  final Duration heartbeatInterval;

  /// Timeout for initial connection.
  final Duration connectionTimeout;

  /// Additional HTTP headers for the WebSocket handshake.
  final Map<String, String> headers;

  /// Query parameters to append to the connection URL.
  final Map<String, dynamic> params;

  const RealtimeConfig({
    required this.url,
    this.reconnectDelay = const Duration(seconds: 2),
    this.maxReconnectAttempts = 5,
    this.heartbeatInterval = const Duration(seconds: 30),
    this.connectionTimeout = const Duration(seconds: 10),
    this.headers = const {},
    this.params = const {},
  });

  /// Returns a copy of this config with the given fields replaced.
  RealtimeConfig copyWith({
    String? url,
    Duration? reconnectDelay,
    int? maxReconnectAttempts,
    Duration? heartbeatInterval,
    Duration? connectionTimeout,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) {
    return RealtimeConfig(
      url: url ?? this.url,
      reconnectDelay: reconnectDelay ?? this.reconnectDelay,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      heartbeatInterval: heartbeatInterval ?? this.heartbeatInterval,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      headers: headers ?? this.headers,
      params: params ?? this.params,
    );
  }

  /// Builds the WebSocket URI with query params appended.
  Uri get uri {
    final base = Uri.parse(url);
    final queryParams = {
      ...base.queryParameters,
      ...params.map((k, v) => MapEntry(k, v.toString())),
    };
    return base.replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  @override
  List<Object?> get props => [
        url,
        reconnectDelay,
        maxReconnectAttempts,
        heartbeatInterval,
        connectionTimeout,
        headers,
        params,
      ];
}
