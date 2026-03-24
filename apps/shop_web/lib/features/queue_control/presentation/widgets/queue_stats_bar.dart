import 'package:flutter/material.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';
import 'package:shop_web/features/queue_control/domain/entities/queue_settings.dart';
import 'package:shop_web/shared/shared.dart';

/// A horizontal bar of key queue metrics displayed at the top of the page.
///
/// Shows total in queue, currently serving count, average wait time, and
/// the estimated time when the last customer will be served.
class QueueStatsBar extends StatelessWidget {
  const QueueStatsBar({
    super.key,
    required this.queueItems,
    required this.settings,
  });

  final List<QueueItem> queueItems;
  final QueueSettings settings;

  int get _totalWaiting =>
      queueItems.where((i) => i.isWaiting).length;

  int get _currentlyServingCount =>
      queueItems.where((i) => i.isServing).length;

  int get _avgWaitMinutes {
    final waiting = queueItems.where((i) => i.isWaiting).toList();
    if (waiting.isEmpty) return 0;
    final total =
        waiting.fold<int>(0, (sum, i) => sum + i.estimatedWaitMinutes);
    return (total / waiting.length).round();
  }

  String get _estimatedFinishTime {
    if (_totalWaiting == 0) return '—';
    final finishMinutes =
        _totalWaiting * settings.avgServiceTimeMinutes;
    final eta = DateTime.now().add(Duration(minutes: finishMinutes));
    final h = eta.hour.toString().padLeft(2, '0');
    final m = eta.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        if (isNarrow) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _buildStatCards(context),
          );
        }
        return Row(
          children: _buildStatCards(context)
              .map((card) => Expanded(child: card))
              .toList(),
        );
      },
    );
  }

  List<Widget> _buildStatCards(BuildContext context) {
    return [
      StatCard(
        label: 'Total in Queue',
        value: _totalWaiting.toString(),
        icon: Icons.people_alt_outlined,
        color: Colors.blue.shade600,
      ),
      StatCard(
        label: 'Serving Now',
        value: _currentlyServingCount.toString(),
        icon: Icons.engineering_outlined,
        color: Colors.green.shade600,
      ),
      StatCard(
        label: 'Avg Wait',
        value: '${_avgWaitMinutes}m',
        icon: Icons.timer_outlined,
        color: Colors.orange.shade700,
      ),
      StatCard(
        label: 'Est. Finish',
        value: _estimatedFinishTime,
        icon: Icons.schedule_rounded,
        color: settings.isActive
            ? Colors.purple.shade600
            : Colors.grey.shade600,
      ),
    ];
  }
}
