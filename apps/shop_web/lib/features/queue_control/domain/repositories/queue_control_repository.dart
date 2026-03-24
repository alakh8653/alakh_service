import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';

/// Contract for all queue control data operations.
abstract class QueueControlRepository {
  /// Fetches the current live queue entries.
  Future<Either<Failure, List<QueueItem>>> getLiveQueue();

  /// Advances the queue by calling the next customer.
  ///
  /// [queueItemId] is the ID of the item to call next.
  Future<Either<Failure, QueueItem>> callNext(String queueItemId);

  /// Permanently removes an item from the queue.
  Future<Either<Failure, void>> removeFromQueue(String id);

  /// Reorders queue items according to [orderedIds].
  Future<Either<Failure, List<QueueItem>>> reorderQueue(
    List<String> orderedIds,
  );

  /// Pauses the queue with an optional [reason].
  Future<Either<Failure, QueueSettings>> pauseQueue(String reason);

  /// Resumes a previously paused queue.
  Future<Either<Failure, QueueSettings>> resumeQueue();

  /// Retrieves the current queue configuration settings.
  Future<Either<Failure, QueueSettings>> getQueueSettings();

  /// Persists updated queue [settings] to the backend.
  Future<Either<Failure, QueueSettings>> updateQueueSettings(
    QueueSettings settings,
  );
}
