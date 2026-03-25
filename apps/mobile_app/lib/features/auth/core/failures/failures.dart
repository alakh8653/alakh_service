import 'package:equatable/equatable.dart';

/// Base class for all failures across the application.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure indicating a server-side error.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure indicating a cache/local storage error.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure indicating a network connectivity error.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure indicating invalid or unexpected input.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure indicating the user is unauthorized.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}
