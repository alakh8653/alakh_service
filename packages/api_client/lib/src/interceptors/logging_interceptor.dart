import 'package:dio/dio.dart';

/// Dio interceptor that logs requests, responses, and errors to stdout.
///
/// The `Authorization` header value is redacted to avoid leaking credentials
/// in logs. Response bodies are truncated to 500 characters.
class LoggingInterceptor extends Interceptor {
  /// Whether to include request/response bodies in log output.
  final bool logBody;

  /// Creates a [LoggingInterceptor].
  ///
  /// Set [logBody] to `false` in production environments to reduce noise.
  const LoggingInterceptor({this.logBody = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final sanitisedHeaders = _sanitiseHeaders(options.headers);
    _log('→ ${options.method.toUpperCase()} ${options.uri}');
    _log('  Headers: $sanitisedHeaders');
    if (logBody && options.data != null) {
      _log('  Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('← ${response.statusCode} ${response.requestOptions.uri}');
    if (logBody && response.data != null) {
      final body = response.data.toString();
      final truncated =
          body.length > 500 ? '${body.substring(0, 500)}…' : body;
      _log('  Body: $truncated');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '✗ ${err.requestOptions.method.toUpperCase()} '
      '${err.requestOptions.uri} → ${err.message}',
    );
    if (err.response != null) {
      _log('  Status: ${err.response?.statusCode}');
    }
    handler.next(err);
  }

  /// Returns a copy of [headers] with the `Authorization` value redacted.
  Map<String, dynamic> _sanitiseHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization')) {
      copy['Authorization'] = '[REDACTED]';
    }
    return copy;
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[ApiClient] $message');
  }
}
