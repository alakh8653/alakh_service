import 'package:equatable/equatable.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';

/// Base class for all queue control events.
abstract class QueueControlEvent extends Equatable {
  const QueueControlEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers initial loading of the queue and settings.
class LoadQueue extends QueueControlEvent {
  const LoadQueue();
}

/// Refreshes the queue (e.g., pull-to-refresh or periodic poll).
class RefreshQueue extends QueueControlEvent {
  const RefreshQueue();
}

/// Calls the next customer; optionally targets a specific queue item.
class CallNextInQueue extends QueueControlEvent {
  const CallNextInQueue({this.preferredId});

  /// When non-null, this specific item is called instead of the first waiting.
  final String? preferredId;

  @override
  List<Object?> get props => [preferredId];
}

/// Removes a customer from the queue.
class RemoveFromQueue extends QueueControlEvent {
  const RemoveFromQueue(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

/// Reorders two queue items identified by their list indices.
class ReorderQueue extends QueueControlEvent {
  const ReorderQueue({required this.oldIndex, required this.newIndex});

  final int oldIndex;
  final int newIndex;

  @override
  List<Object> get props => [oldIndex, newIndex];
}

/// Pauses the queue with a required reason string.
class PauseQueue extends QueueControlEvent {
  const PauseQueue(this.reason);

  final String reason;

  @override
  List<Object> get props => [reason];
}

/// Resumes a previously paused queue.
class ResumeQueue extends QueueControlEvent {
  const ResumeQueue();
}

/// Persists new queue configuration settings.
class UpdateQueueSettings extends QueueControlEvent {
  const UpdateQueueSettings(this.settings);

  final QueueSettings settings;

  @override
  List<Object> get props => [settings];
}
