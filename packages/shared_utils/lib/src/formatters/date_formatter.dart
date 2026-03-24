import 'package:intl/intl.dart';

/// Utility class for formatting [DateTime] and [Duration] values into
/// human-readable strings.
class DateFormatter {
  DateFormatter._();

  /// Formats [date] as `dd MMM yyyy` (e.g. `05 Jan 2024`).
  static String formatDate(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  /// Formats [date] as `hh:mm a` (e.g. `09:30 AM`).
  static String formatTime(DateTime date) =>
      DateFormat('hh:mm a').format(date);

  /// Formats [date] as `dd MMM yyyy, hh:mm a` (e.g. `05 Jan 2024, 09:30 AM`).
  static String formatDateTime(DateTime date) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(date);

  /// Formats a [Duration] into a human-readable string.
  ///
  /// Examples:
  /// - `Duration(seconds: 45)` → `"45s"`
  /// - `Duration(minutes: 3, seconds: 20)` → `"3m 20s"`
  /// - `Duration(hours: 2, minutes: 5)` → `"2h 5m"`
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    if (minutes > 0) {
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    }
    return '${seconds}s';
  }

  /// Returns a relative time string representing how long ago [date] was.
  ///
  /// Examples:
  /// - < 60 seconds ago → `"just now"`
  /// - < 60 minutes ago → `"2 minutes ago"`
  /// - < 24 hours ago  → `"3 hours ago"`
  /// - exactly 1 day ago → `"yesterday"`
  /// - < 7 days ago    → `"2 days ago"`
  /// - otherwise       → formatted date via [formatDate]
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    }
    return formatDate(date);
  }
}
