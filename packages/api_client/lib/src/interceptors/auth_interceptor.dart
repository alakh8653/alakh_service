import '../token/token_provider.dart';
import 'package:dio/dio.dart';

export '../token/token_provider.dart';

/// Dio interceptor that attaches a Bearer token to every outgoing request.
///
/// The token is fetched from [tokenProvider] before each request. If no token
/// is available the request is forwarded without an `Authorization` header.
class AuthInterceptor extends Interceptor {
  /// Provider used to retrieve the current access token.
  final TokenProvider tokenProvider;

  /// Creates an [AuthInterceptor] backed by the given [tokenProvider].
  AuthInterceptor(this.tokenProvider);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
