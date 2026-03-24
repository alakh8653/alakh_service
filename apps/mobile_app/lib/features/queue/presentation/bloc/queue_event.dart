import 'package:equatable/equatable.dart';

import '../../domain/entities/queue_entry.dart';

/// Base class for all queue BLoC events.
abstract class QueueEvent extends Equatable {
  /// Creates a [QueueEvent].
  const QueueEvent();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when the user wants to join a shop's queue.
class JoinQueueEvent extends QueueEvent {
  /// The shop the user wants to queue at.
  final String shopId;

  /// Optional service identifier within the shop.
  final String? serviceId;

  /// Creates a [JoinQueueEvent].
  const JoinQueueEvent({required this.shopId, this.serviceId});

  @override
  List<Object?> get props => [shopId, serviceId];
}

/// Event dispatched when the user wants to leave/cancel their queue entry.
class LeaveQueueEvent extends QueueEvent {
  /// The queue entry to cancel.
  final String entryId;

  /// Creates a [LeaveQueueEvent].
  const LeaveQueueEvent({required this.entryId});

  @override
  List<Object?> get props => [entryId];
}

/// Event dispatched to fetch the current queue status for a shop.
class LoadQueueStatusEvent extends QueueEvent {
  /// The shop whose queue status should be loaded.
  final String shopId;

  /// Creates a [LoadQueueStatusEvent].
  const LoadQueueStatusEvent({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

/// Event dispatched to begin listening for live position updates.
class WatchPositionEvent extends QueueEvent {
  /// The queue entry to subscribe to.
  final String entryId;

  /// Creates a [WatchPositionEvent].
  const WatchPositionEvent({required this.entryId});

  @override
  List<Object?> get props => [entryId];
}

/// Event dispatched to manually refresh queue status and position.
class RefreshQueueEvent extends QueueEvent {
  /// The shop whose queue should be refreshed.
  final String shopId;

  /// Creates a [RefreshQueueEvent].
  const RefreshQueueEvent({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

/// Event dispatched to load the authenticated user's queue history.
class LoadQueueHistoryEvent extends QueueEvent {
  /// Creates a [LoadQueueHistoryEvent].
  const LoadQueueHistoryEvent();
}

/// Internal event emitted when a live position update arrives from the stream.
///
/// Not intended to be dispatched externally.
class _QueuePositionUpdateReceived extends QueueEvent {
  /// The updated queue entry.
  final QueueEntry entry;

  const _QueuePositionUpdateReceived(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Internal event emitted when the live position stream emits an error.
///
/// Not intended to be dispatched externally.
class _QueueStreamErrorReceived extends QueueEvent {
  /// The error message from the stream.
  final String message;

  const _QueueStreamErrorReceived(this.message);

  @override
  List<Object?> get props => [message];
}
