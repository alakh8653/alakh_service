import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
///
/// Use [Either<Failure, T>] from the dartz package to propagate errors
/// through the domain and presentation layers without throwing exceptions.
abstract class Failure extends Equatable {
  /// Human-readable description of the failure.
  final String message;

  /// Optional underlying error object for debugging.
  final Object? cause;

  /// Creates a [Failure] with a [message] and optional [cause].
  const Failure({required this.message, this.cause});

  @override
  List<Object?> get props => [message, cause];
}

/// Failure originating from a server or network request.
class ServerFailure extends Failure {
  /// HTTP status code, if available.
  final int? statusCode;

  /// Creates a [ServerFailure].
  const ServerFailure({
    required super.message,
    this.statusCode,
    super.cause,
  });

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Failure due to the device being offline or unreachable.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure({super.message = 'No internet connection.', super.cause});
}

/// Failure when locally cached data is absent or expired.
class CacheFailure extends Failure {
  /// Creates a [CacheFailure].
  const CacheFailure({super.message = 'No cached data found.', super.cause});
}

/// Failure due to bad or unexpected input.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure({required super.message, super.cause});
}

/// Failure when the requested resource could not be found.
class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure].
  const NotFoundFailure({super.message = 'Resource not found.', super.cause});
}

/// Failure when the user is not authorised to perform the action.
class UnauthorisedFailure extends Failure {
  /// Creates an [UnauthorisedFailure].
  const UnauthorisedFailure({
    super.message = 'You are not authorised to perform this action.',
    super.cause,
  });
}
