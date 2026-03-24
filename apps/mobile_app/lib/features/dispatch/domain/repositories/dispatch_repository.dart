import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dispatch_job.dart';
import '../entities/dispatch_route.dart';
import '../entities/dispatch_status.dart';

/// Abstract contract for all dispatch data operations.
///
/// Implementations live in the data layer and are injected via dependency
/// injection so the domain layer stays infrastructure-agnostic.
abstract class DispatchRepository {
  /// Accepts the dispatch job identified by [jobId].
  Future<Either<Failure, Unit>> acceptDispatch(String jobId);

  /// Rejects the dispatch job identified by [jobId].
  ///
  /// An optional [reason] string may be provided for audit logging.
  Future<Either<Failure, Unit>> rejectDispatch(String jobId, {String? reason});

  /// Fetches the currently active (non-terminal) job for the logged-in staff.
  ///
  /// Returns `null` when there is no active job.
  Future<Either<Failure, DispatchJob?>> getActiveDispatch();

  /// Transitions [jobId] to the supplied [status].
  Future<Either<Failure, Unit>> updateDispatchStatus(
    String jobId,
    DispatchStatus status,
  );

  /// Retrieves the navigable route for [jobId].
  Future<Either<Failure, DispatchRoute>> getDispatchRoute(String jobId);

  /// Returns a broadcast stream of real-time job updates for [staffId].
  ///
  /// Each event is wrapped in [Either] so errors are handled in-band.
  Stream<Either<Failure, DispatchJob>> watchDispatchUpdates(String staffId);

  /// Retrieves a paginated list of completed or cancelled jobs.
  Future<Either<Failure, List<DispatchJob>>> getDispatchHistory({int page = 1});
}
