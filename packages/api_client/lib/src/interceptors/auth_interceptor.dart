import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccessTokenKey = 'access_token';
const _kRefreshTokenKey = 'refresh_token';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.secureStorage});

  final Dio dio;
  final FlutterSecureStorage secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.read(key: _kAccessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await secureStorage.read(key: _kRefreshTokenKey);
        if (refreshToken == null) {
          handler.next(err);
          return;
        }

        final response = await dio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
          options: Options(extra: {'skipAuth': true}),
        );

        final newAccessToken = response.data?['data']?['accessToken'] as String?;
        if (newAccessToken != null) {
          await secureStorage.write(key: _kAccessTokenKey, value: newAccessToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch<dynamic>(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (_) {
        // Refresh failed — fall through to propagate original error
      }
    }
    handler.next(err);
  }
}
