import 'package:dio/dio.dart';

/// A simple in-memory cache interceptor for GET requests.
///
/// Responses to GET requests are stored with an expiry time determined by
/// [cacheDuration]. Subsequent identical requests (same URL + query params)
/// are served from the cache until the entry expires.
///
/// Only successful (2xx) responses are cached. Cache keys incorporate the
/// HTTP method, full URI (including query parameters).
class CacheInterceptor extends Interceptor {
  /// How long a cached entry remains valid.
  final Duration cacheDuration;

  final Map<String, _CacheEntry> _cache = {};

  /// Creates a [CacheInterceptor] with the given [cacheDuration].
  CacheInterceptor({this.cacheDuration = const Duration(minutes: 5)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() != 'GET') {
      handler.next(options);
      return;
    }

    final key = _cacheKey(options);
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      handler.resolve(
        Response(
          requestOptions: options,
          data: entry.data,
          statusCode: entry.statusCode,
          headers: entry.headers,
        ),
        true,
      );
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final method = response.requestOptions.method.toUpperCase();
    final statusCode = response.statusCode ?? 0;
    if (method == 'GET' && statusCode >= 200 && statusCode < 300) {
      final key = _cacheKey(response.requestOptions);
      _cache[key] = _CacheEntry(
        data: response.data,
        statusCode: statusCode,
        headers: response.headers,
        expiresAt: DateTime.now().add(cacheDuration),
      );
    }
    handler.next(response);
  }

  /// Removes all entries from the cache.
  void clearCache() => _cache.clear();

  /// Removes the cached entry for [options], if present.
  void invalidate(RequestOptions options) => _cache.remove(_cacheKey(options));

  String _cacheKey(RequestOptions options) {
    return '${options.method.toUpperCase()}:${options.uri}';
  }
}

/// Internal model representing a single cache entry.
class _CacheEntry {
  final dynamic data;
  final int statusCode;
  final Headers headers;
  final DateTime expiresAt;

  const _CacheEntry({
    required this.data,
    required this.statusCode,
    required this.headers,
    required this.expiresAt,
  });

  /// Returns `true` if this entry has passed its expiry time.
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
