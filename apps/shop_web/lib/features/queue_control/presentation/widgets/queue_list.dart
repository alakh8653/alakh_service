import 'package:flutter/material.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/presentation/widgets/queue_item_card.dart';

/// A reorderable list of [QueueItemCard]s representing the live queue.
///
/// Only items with a `waiting` status can be reordered; the currently serving
/// item is pinned at the top and excluded from drag interactions.
class QueueList extends StatelessWidget {
  const QueueList({
    super.key,
    required this.items,
    required this.onReorder,
    required this.onCallNext,
    required this.onRemove,
    this.currentlyServingId,
  });

  /// Full list of queue items to display (waiting + serving).
  final List<QueueItem> items;

  /// Called when the user drags an item from [oldIndex] to [newIndex].
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Called when the "Call Next" action is triggered for a specific item id.
  final void Function(String id) onCallNext;

  /// Called when the "Remove" action is triggered for a specific item id.
  final void Function(String id) onRemove;

  /// The id of the item currently being served, if any.
  final String? currentlyServingId;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Separate serving item (pinned) from waiting items (reorderable).
    final servingItem =
        items.where((i) => i.isServing).isNotEmpty
            ? items.firstWhere((i) => i.isServing)
            : null;
    final waitingItems = items.where((i) => i.isWaiting).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (servingItem != null) ...[
          _SectionHeader(label: 'Now Serving'),
          QueueItemCard(
            item: servingItem,
            onCallNext: () => onCallNext(servingItem.id),
            onRemove: () => onRemove(servingItem.id),
            isCurrentlyServing: true,
          ),
          const SizedBox(height: 16),
        ],
        if (waitingItems.isNotEmpty) ...[
          _SectionHeader(label: 'Waiting (${waitingItems.length})'),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: waitingItems.length,
            onReorder: onReorder,
            proxyDecorator: (child, index, animation) => Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: child,
            ),
            itemBuilder: (context, index) {
              final item = waitingItems[index];
              return Padding(
                key: ValueKey(item.id),
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(
                          Icons.drag_handle_rounded,
                          color: Colors.grey,
                          size: 22,
                        ),
                      ),
                    ),
                    Expanded(
                      child: QueueItemCard(
                        item: item,
                        onCallNext: () => onCallNext(item.id),
                        onRemove: () => onRemove(item.id),
                        isCurrentlyServing: false,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[700]),
      ),
    );
  }
}
