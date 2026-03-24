/// Domain-layer failure types, use-case base class, and error-handler utility.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'shop_exceptions.dart';

// ---------------------------------------------------------------------------
// Failures
// ---------------------------------------------------------------------------

/// Base class for all domain-level failures.
///
/// Failures are the domain-safe counterparts of [Exception]s and are returned
/// from use-cases via [Either].
abstract class Failure extends Equatable {
  /// Creates a [Failure] with the given [message].
  const Failure({required this.message});

  /// User-facing or log-friendly description of the failure.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Represents a server-side error (5xx, unexpected payload, etc.).
class ServerFailure extends Failure {
  /// Creates a [ServerFailure].
  const ServerFailure({required super.message, this.statusCode});

  /// Optional HTTP status code returned by the server.
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a connectivity or network-transport error.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure({required super.message});
}

/// Represents an authentication or authorisation failure.
class AuthFailure extends Failure {
  /// Creates an [AuthFailure].
  const AuthFailure({required super.message, this.statusCode});

  /// Optional HTTP status code (e.g. 401, 403).
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a local-cache read/write failure.
class CacheFailure extends Failure {
  /// Creates a [CacheFailure].
  const CacheFailure({required super.message});
}

/// Represents a validation error raised by the server or the client.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
  });

  /// Per-field validation messages keyed by field name.
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Represents an operation that exceeded its allowed time limit.
class TimeoutFailure extends Failure {
  /// Creates a [TimeoutFailure].
  const TimeoutFailure({required super.message});
}

// ---------------------------------------------------------------------------
// Use-case base class
// ---------------------------------------------------------------------------

/// Marker class used as the parameter type when a use-case needs no input.
class NoParams extends Equatable {
  /// Creates [NoParams].
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Abstract base class for all use-cases in the application.
///
/// Type parameter [Type] is the success value type.
/// Type parameter [Params] is the input parameter type (use [NoParams] when
/// the use-case requires no input).
abstract class UseCase<Type, Params> {
  /// Executes the use-case with the supplied [params].
  ///
  /// Returns [Right] on success and [Left] on failure.
  Future<Either<Failure, Type>> call(Params params);
}

// ---------------------------------------------------------------------------
// Error handler
// ---------------------------------------------------------------------------

/// Utility that converts raw [Exception]s into typed [Failure] objects.
class ShopErrorHandler {
  /// Converts [exception] to the most specific [Failure] subclass available.
  ///
  /// Falls back to [ServerFailure] for unrecognised exception types.
  static Failure handleException(Exception exception) {
    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    }

    if (exception is AuthException) {
      return AuthFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    }

    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    }

    if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    }

    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        fieldErrors: exception.fieldErrors,
      );
    }

    if (exception is TimeoutException) {
      return TimeoutFailure(message: exception.message);
    }

    // Fallback for any unrecognised exception type.
    return ServerFailure(
      message: exception.toString(),
    );
  }
}
