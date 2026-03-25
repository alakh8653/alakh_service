import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_web/features/dashboard/domain/entities/recent_activity.dart';
import 'package:shop_web/shared/shared.dart';

/// Feed of recent activity events displayed on the Dashboard sidebar.
///
/// Each item shows a type-specific icon, colour, title, description, and a
/// human-readable "time ago" label.
class ActivityFeed extends StatelessWidget {
  final List<RecentActivity> activities;

  const ActivityFeed({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const EmptyTableState(message: 'No recent activity.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _ActivityItem(activity: activities[index]),
            ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final RecentActivity activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final cfg = _typeConfig(activity.type);
    final timeAgo = _formatTimeAgo(activity.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cfg.color.withOpacity(0.15),
            child: Icon(cfg.icon, size: 18, color: cfg.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeAgo,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  _TypeConfig _typeConfig(String type) {
    switch (type) {
      case 'booking':
        return _TypeConfig(Icons.calendar_today_rounded, Colors.blue);
      case 'payment':
        return _TypeConfig(Icons.payment_rounded, Colors.green);
      case 'review':
        return _TypeConfig(Icons.star_rounded, Colors.amber);
      case 'queue':
      default:
        return _TypeConfig(Icons.people_alt_rounded, Colors.orange);
    }
  }

  String _formatTimeAgo(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('d MMM').format(ts.toLocal());
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  const _TypeConfig(this.icon, this.color);
}
