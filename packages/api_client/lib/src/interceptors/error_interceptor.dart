import 'package:dio/dio.dart';
import '../api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapToApiException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
        message: apiException.message,
      ),
    );
  }

  ApiException _mapToApiException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException(message: 'No internet connection');
      case DioExceptionType.badResponse:
        return _mapStatusCode(err);
      default:
        return UnknownException(message: err.message ?? 'An unknown error occurred');
    }
  }

  ApiException _mapStatusCode(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final message = _extractMessage(err.response);

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 422:
        return ValidationException(message: message);
      default:
        if (statusCode >= 500) {
          return ServerException(message: message, statusCode: statusCode);
        }
        return UnknownException(message: message);
    }
  }

  String _extractMessage(Response<dynamic>? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'An error occurred';
      }
    } catch (_) {}
    return 'An error occurred';
  }
}
