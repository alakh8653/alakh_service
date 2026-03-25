import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
abstract class Failure extends Equatable {
  /// Human-readable description of the failure.
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure originating from a remote server.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure originating from local cache/storage.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure due to network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
