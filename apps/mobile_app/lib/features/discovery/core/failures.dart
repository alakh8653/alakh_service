import 'package:equatable/equatable.dart';

/// Base class for all domain failures.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Failure originating from a remote API call.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure originating from local cache/storage.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure due to missing or unavailable network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
