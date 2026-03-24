import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/queue_entry.dart';
import '../repositories/queue_repository.dart';

/// Use case that returns a live stream of position/status updates for a queue
/// entry.
///
/// Single-responsibility: delegates directly to
/// [QueueRepository.watchQueueUpdates].
class WatchQueueUpdatesUseCase {
  /// The repository used to open the real-time stream.
  final QueueRepository repository;

  /// Creates a [WatchQueueUpdatesUseCase] with the given [repository].
  const WatchQueueUpdatesUseCase(this.repository);

  /// Returns a stream that emits [QueueEntry] updates for [params.entryId].
  Stream<Either<Failure, QueueEntry>> call(WatchQueueUpdatesParams params) =>
      repository.watchQueueUpdates(params.entryId);
}

/// Parameters required to execute [WatchQueueUpdatesUseCase].
class WatchQueueUpdatesParams extends Equatable {
  /// The queue entry identifier to subscribe to.
  final String entryId;

  /// Creates [WatchQueueUpdatesParams].
  const WatchQueueUpdatesParams({required this.entryId});

  @override
  List<Object?> get props => [entryId];
}
