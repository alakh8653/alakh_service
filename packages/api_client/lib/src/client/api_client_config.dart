import 'package:equatable/equatable.dart';

/// Configuration for the API client, including base URL, timeouts, and headers.
class ApiClientConfig extends Equatable {
  /// The base URL for all API requests.
  final String baseUrl;

  /// Maximum time to wait while establishing a connection.
  final Duration connectTimeout;

  /// Maximum time to wait for the server to send a response.
  final Duration receiveTimeout;

  /// Maximum time to wait while sending request data.
  final Duration sendTimeout;

  /// Additional default headers merged with every request.
  final Map<String, String> headers;

  const ApiClientConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.headers = const {},
  });

  /// Returns the merged default headers, always including `Content-Type: application/json`.
  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...headers,
      };

  /// Returns a copy of this config with the given fields replaced.
  ApiClientConfig copyWith({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? headers,
  }) {
    return ApiClientConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      headers: headers ?? this.headers,
    );
  }

  @override
  List<Object?> get props => [
        baseUrl,
        connectTimeout,
        receiveTimeout,
        sendTimeout,
        headers,
      ];
}
