/// Preconfigured Dio HTTP client for the Shop Web application.
library;

import 'package:dio/dio.dart';

import '../security/shop_session_manager.dart';
import 'shop_api_endpoints.dart';
import 'shop_api_interceptors.dart';

/// A thin wrapper around [Dio] that wires up base options and all application
/// interceptors.
///
/// Obtain an instance via [ShopApiClient.create] or register it with GetIt.
class ShopApiClient {
  /// Creates a fully configured [ShopApiClient].
  ///
  /// The [sessionManager] is forwarded to [ShopAuthInterceptor] so that auth
  /// tokens are read and refreshed transparently.
  ShopApiClient.create({required ShopSessionManager sessionManager})
      : _dio = _buildDio(sessionManager);

  /// Constructs a [ShopApiClient] from an already-configured [Dio] instance.
  ///
  /// Useful for unit testing where a mock [Dio] is injected directly.
  ShopApiClient.fromDio(Dio dio) : _dio = dio;

  final Dio _dio;

  // -------------------------------------------------------------------------
  // Internal factory
  // -------------------------------------------------------------------------

  static Dio _buildDio(ShopSessionManager sessionManager) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ShopApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Client': 'shop-web/1.0.0',
        },
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      ShopAuthInterceptor(sessionManager: sessionManager),
      ShopErrorInterceptor(),
      ShopLoggingInterceptor(),
    ]);

    return dio;
  }

  // -------------------------------------------------------------------------
  // Convenience HTTP methods
  // -------------------------------------------------------------------------

  /// Performs a GET request to [path].
  ///
  /// Optional [queryParameters] are appended to the URL.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  /// Performs a POST request to [path] with optional [data] body.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  /// Performs a PUT request to [path] with optional [data] body.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);

  /// Performs a PATCH request to [path] with optional [data] body.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);

  /// Performs a DELETE request to [path].
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);

  /// Uploads a file using a multipart POST request to [path].
  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    Options? options,
  }) =>
      _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options ??
            Options(
              headers: {'Content-Type': 'multipart/form-data'},
            ),
      );
}
