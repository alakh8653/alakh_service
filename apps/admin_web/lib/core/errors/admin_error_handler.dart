import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:admin_web/core/errors/failures.dart';

class AdminErrorHandler {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void handleFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      _logger.e(
        'Flutter Error',
        error: details.exception,
        stackTrace: details.stack,
      );
    }
  }

  static String handleError(Object error, StackTrace stackTrace) {
    _logger.e('Unhandled error', error: error, stackTrace: stackTrace);

    if (error is DioException) {
      return _dioErrorMessage(error);
    }

    return error.toString();
  }

  static Failure handleDioException(dynamic error) {
    if (error is! DioException) {
      return ServerFailure(error.toString());
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkFailure('Connection timed out. Please check your network.');

      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        final serverMessage = _extractServerMessage(data);

        if (statusCode == 400) {
          return ValidationFailure(serverMessage ?? 'Invalid request. Please check your input.');
        } else if (statusCode == 401) {
          return const UnauthorizedFailure('Session expired. Please login again.');
        } else if (statusCode == 403) {
          return const UnauthorizedFailure('You do not have permission to perform this action.');
        } else if (statusCode == 404) {
          return NotFoundFailure(serverMessage ?? 'The requested resource was not found.');
        } else if (statusCode != null && statusCode >= 500) {
          return ServerFailure(serverMessage ?? 'Server error. Please try again later.');
        }
        return ServerFailure(serverMessage ?? 'An unexpected error occurred.');

      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkFailure('SSL certificate error.');

      case DioExceptionType.unknown:
      default:
        return NetworkFailure(error.message ?? 'An unknown error occurred.');
    }
  }

  static String _dioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return _extractServerMessage(error.response?.data) ??
            'Server error (${error.response?.statusCode})';
      default:
        return error.message ?? 'An unknown error occurred.';
    }
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}
