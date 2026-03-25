import 'package:equatable/equatable.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';

/// Base class for all queue control states.
abstract class QueueControlState extends Equatable {
  const QueueControlState();

  @override
  List<Object?> get props => [];
}

/// The BLoC has just been created and no data has been fetched yet.
class QueueControlInitial extends QueueControlState {
  const QueueControlInitial();
}

/// A full-screen loading indicator while data is being fetched.
class QueueControlLoading extends QueueControlState {
  const QueueControlLoading();
}

/// Data has been loaded successfully.
class QueueControlLoaded extends QueueControlState {
  const QueueControlLoaded({
    required this.queueItems,
    required this.settings,
    this.currentlyServing,
  });

  final List<QueueItem> queueItems;
  final QueueSettings settings;

  /// The queue item currently being served, if any.
  final QueueItem? currentlyServing;

  /// Convenience: items that are still waiting.
  List<QueueItem> get waitingItems =>
      queueItems.where((i) => i.isWaiting).toList();

  QueueControlLoaded copyWith({
    List<QueueItem>? queueItems,
    QueueSettings? settings,
    QueueItem? currentlyServing,
    bool clearCurrentlyServing = false,
  }) {
    return QueueControlLoaded(
      queueItems: queueItems ?? this.queueItems,
      settings: settings ?? this.settings,
      currentlyServing: clearCurrentlyServing
          ? null
          : currentlyServing ?? this.currentlyServing,
    );
  }

  @override
  List<Object?> get props => [queueItems, settings, currentlyServing];
}

/// An action is being performed while the loaded data remains visible.
///
/// Extends [QueueControlLoaded] so the UI can keep showing the queue
/// while displaying an in-progress indicator.
class QueueActionInProgress extends QueueControlLoaded {
  const QueueActionInProgress({
    required super.queueItems,
    required super.settings,
    super.currentlyServing,
    required this.actionDescription,
  });

  /// Short human-readable description of the in-flight action (for debugging).
  final String actionDescription;

  @override
  List<Object?> get props => [
        ...super.props,
        actionDescription,
      ];
}

/// An error occurred; [message] describes what went wrong.
class QueueControlError extends QueueControlState {
  const QueueControlError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
