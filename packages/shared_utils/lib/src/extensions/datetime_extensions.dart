import '../formatters/date_formatter.dart';

/// Convenient extension methods on [DateTime].
extension DateTimeExtensions on DateTime {
  /// Returns `true` when this date falls on today's calendar date.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns `true` when this date falls on yesterday's calendar date.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns `true` when this date falls on tomorrow's calendar date.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Returns `true` when this date falls within the current calendar week
  /// (Monday–Sunday).
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.startOfWeek;
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        isBefore(endOfWeek);
  }

  /// Returns `true` when this date falls within the current calendar month.
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Returns a human-readable relative time string (e.g. `"2 minutes ago"`).
  String get timeAgo => DateFormatter.timeAgo(this);

  /// Returns this date formatted as `dd MMM yyyy`.
  String get formatDate => DateFormatter.formatDate(this);

  /// Returns this time formatted as `hh:mm a`.
  String get formatTime => DateFormatter.formatTime(this);

  /// Returns a new [DateTime] at midnight (00:00:00) on the same calendar date.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns a new [DateTime] at the very end of the same calendar date
  /// (23:59:59.999).
  DateTime get endOfDay =>
      DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns the [DateTime] of the most recent Monday at midnight.
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1; // Monday == 1
    return DateTime(year, month, day - daysFromMonday);
  }

  /// Returns the first day of the same calendar month at midnight.
  DateTime get startOfMonth => DateTime(year, month);

  /// Adds [n] working days (Monday–Friday) to this [DateTime].
  DateTime addWorkdays(int n) {
    var result = this;
    var remaining = n;
    while (remaining > 0) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        remaining--;
      }
    }
    return result;
  }
}
