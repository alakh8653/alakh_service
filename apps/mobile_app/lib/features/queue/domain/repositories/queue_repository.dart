import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/queue.dart';
import '../entities/queue_entry.dart';

/// Abstract repository contract for all queue-related operations.
///
/// Concrete implementations live in the data layer and are injected
/// via dependency injection. All methods return [Either] so callers
/// can handle failures without exceptions.
abstract class QueueRepository {
  /// Joins the queue for [shopId], optionally requesting a specific [serviceId].
  ///
  /// Returns the newly created [QueueEntry] on success.
  Future<Either<Failure, QueueEntry>> joinQueue(
    String shopId, {
    String? serviceId,
  });

  /// Removes the entry identified by [entryId] from its queue.
  ///
  /// Returns [Unit] on success.
  Future<Either<Failure, Unit>> leaveQueue(String entryId);

  /// Fetches the current [Queue] state for the given [shopId].
  Future<Either<Failure, Queue>> getQueueStatus(String shopId);

  /// Retrieves the caller's own [QueueEntry] from [queueId].
  Future<Either<Failure, QueueEntry>> getMyQueuePosition(String queueId);

  /// Returns a live stream of [QueueEntry] updates for [entryId].
  ///
  /// The stream emits a new value whenever the server pushes a position
  /// or status change. The stream never completes until the caller cancels it.
  Stream<Either<Failure, QueueEntry>> watchQueueUpdates(String entryId);

  /// Retrieves the authenticated user's historical queue entries.
  Future<Either<Failure, List<QueueEntry>>> getQueueHistory();
}
