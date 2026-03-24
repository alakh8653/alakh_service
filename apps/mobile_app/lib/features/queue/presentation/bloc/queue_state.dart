import 'package:equatable/equatable.dart';

import '../../domain/entities/queue.dart';
import '../../domain/entities/queue_entry.dart';

/// Base class for all queue BLoC states.
abstract class QueueState extends Equatable {
  /// Creates a [QueueState].
  const QueueState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any queue action has been taken.
class QueueInitial extends QueueState {
  /// Creates a [QueueInitial] state.
  const QueueInitial();
}

/// State while any asynchronous queue operation is in progress.
class QueueLoading extends QueueState {
  /// Creates a [QueueLoading] state.
  const QueueLoading();
}

/// State after the user has successfully joined a queue.
class QueueJoined extends QueueState {
  /// The queue entry that was created.
  final QueueEntry entry;

  /// Creates a [QueueJoined] state.
  const QueueJoined({required this.entry});

  @override
  List<Object?> get props => [entry];
}

/// State after the queue status for a shop has been loaded.
class QueueStatusLoaded extends QueueState {
  /// The current state of the queue.
  final Queue queue;

  /// Creates a [QueueStatusLoaded] state.
  const QueueStatusLoaded({required this.queue});

  @override
  List<Object?> get props => [queue];
}

/// State emitted when a live position update is received from the server.
class QueuePositionUpdated extends QueueState {
  /// The updated queue entry containing the new position and status.
  final QueueEntry entry;

  /// Creates a [QueuePositionUpdated] state.
  const QueuePositionUpdated({required this.entry});

  @override
  List<Object?> get props => [entry];
}

/// State emitted when the queue entry has reached a terminal status
/// (completed, cancelled, or no-show).
class QueueCompleted extends QueueState {
  /// The finalised queue entry.
  final QueueEntry entry;

  /// Creates a [QueueCompleted] state.
  const QueueCompleted({required this.entry});

  @override
  List<Object?> get props => [entry];
}

/// State emitted when the user's queue history has been successfully loaded.
class QueueHistoryLoaded extends QueueState {
  /// The list of past queue entries, newest first.
  final List<QueueEntry> entries;

  /// Creates a [QueueHistoryLoaded] state.
  const QueueHistoryLoaded({required this.entries});

  @override
  List<Object?> get props => [entries];
}
  /// Human-readable description of the error.
  final String message;

  /// Creates a [QueueError] state.
  const QueueError({required this.message});

  @override
  List<Object?> get props => [message];
}
