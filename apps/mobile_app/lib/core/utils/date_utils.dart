/// Date formatting and parsing utilities.
library date_utils;

// Note: Avoid importing dart:core 'DateUtils' to prevent name clash.

/// Application date/time helpers.
abstract final class AppDateUtils {
  AppDateUtils._();

  // ── Formatters ────────────────────────────────────────────────────────────

  /// Formats [date] as `dd MMM yyyy` (e.g. `05 Jan 2024`).
  static String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dd = date.day.toString().padLeft(2, '0');
    final mmm = months[date.month - 1];
    return '$dd $mmm ${date.year}';
  }

  /// Formats [time] as `HH:mm` in 24-hour format.
  static String formatTime(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  /// Formats [time] as `hh:mm AM/PM`.
  static String formatTime12h(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final mm = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$mm $period';
  }

  /// Formats [dt] as a full date-time string: `dd MMM yyyy, HH:mm`.
  static String formatDateTime(DateTime dt) =>
      '${formatDate(dt)}, ${formatTime(dt)}';

  /// Returns a relative label like "Just now", "5 min ago", "Yesterday", etc.
  static String timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  // ── Parsers ───────────────────────────────────────────────────────────────

  /// Parses an ISO 8601 string into a [DateTime], returning `null` on failure.
  static DateTime? tryParseIso(String? value) =>
      value == null ? null : DateTime.tryParse(value);

  /// Parses an ISO 8601 string or throws a [FormatException].
  static DateTime parseIso(String value) => DateTime.parse(value);

  // ── Range helpers ─────────────────────────────────────────────────────────

  /// Returns a [DateTime] at midnight (00:00:00) for the given [date].
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Returns a [DateTime] at 23:59:59.999 for the given [date].
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  /// Returns `true` if [date] falls on today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns `true` if [date] falls on yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Returns the number of days between [from] and [to] (absolute value).
  static int daysBetween(DateTime from, DateTime to) =>
      startOfDay(to).difference(startOfDay(from)).inDays.abs();
}
