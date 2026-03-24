import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  /// Returns a human-readable date string, e.g. "24 Mar 2026".
  String get displayDate => DateFormat('dd MMM yyyy').format(this);

  /// Returns a human-readable time string, e.g. "03:45 PM".
  String get displayTime => DateFormat('hh:mm a').format(this);

  /// Returns a combined date-time string, e.g. "24 Mar 2026, 03:45 PM".
  String get displayDateTime => '$displayDate, $displayTime';

  /// Returns true if the date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if the date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns a friendly label: "Today", "Yesterday", or the display date.
  String get friendlyDate {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return displayDate;
  }

  /// Returns a relative time description (e.g. "2 hours ago").
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return displayDate;
  }
}
