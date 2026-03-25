import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String get toFormattedDate => DateFormat('dd MMM yyyy').format(this);

  String get toFormattedDateTime => DateFormat('dd MMM yyyy, hh:mm a').format(this);

  String get toTimeString => DateFormat('hh:mm a').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  String get toRelativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return toFormattedDate;
  }
}

extension NullableDateExtensions on DateTime? {
  String get orEmpty => this == null ? '' : this!.toFormattedDate;
}
