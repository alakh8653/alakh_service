import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_exceptions.dart';
import 'api_interceptors.dart';

/// Dio HTTP client configured with base URL, auth interceptor, and logging.
class ApiClient {
  ApiClient({
    required String baseUrl,
    String? Function()? getAccessToken,
    Future<String?> Function()? refreshToken,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(
        getAccessToken: getAccessToken,
        refreshToken: refreshToken,
      ),
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          handler.next(_mapException(e));
        },
      ),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {dynamic data}) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);

  DioException _mapException(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return DioException(
          requestOptions: e.requestOptions,
          error: UnauthorizedException(e.message ?? 'Unauthorized'),
          type: e.type,
          response: e.response,
        );
      case 403:
        return DioException(
          requestOptions: e.requestOptions,
          error: ForbiddenException(e.message ?? 'Forbidden'),
          type: e.type,
          response: e.response,
        );
      case 404:
        return DioException(
          requestOptions: e.requestOptions,
          error: NotFoundException(e.message ?? 'Not found'),
          type: e.type,
          response: e.response,
        );
      case 422:
        return DioException(
          requestOptions: e.requestOptions,
          error: ValidationException(
            e.message ?? 'Validation failed',
            errors: e.response?.data?['errors'] as Map<String, dynamic>?,
          ),
          type: e.type,
          response: e.response,
        );
      case 500:
      case 502:
      case 503:
        return DioException(
          requestOptions: e.requestOptions,
          error: ServerException(e.message ?? 'Server error'),
          type: e.type,
          response: e.response,
        );
      default:
        return e;
    }
  }
}
