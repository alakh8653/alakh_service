/// [DateTime] extension methods for formatting and comparison.
library;

/// Practical helpers on [DateTime].
extension DateTimeExtensions on DateTime {
  // ---------------------------------------------------------------------------
  // Relative time
  // ---------------------------------------------------------------------------

  /// Returns a human-readable "time ago" string (e.g. `"2 hours ago"`).
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months ${months == 1 ? "month" : "months"} ago';
    }
    final years = (diff.inDays / 365).floor();
    return '$years ${years == 1 ? "year" : "years"} ago';
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  /// Formats as `dd MMM yyyy` (e.g. `"05 Jan 2025"`).
  String get formatDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${day.toString().padLeft(2, '0')} ${months[month - 1]} $year';
  }

  /// Formats as `dd/MM/yyyy` (e.g. `"05/01/2025"`).
  String get formatSlash =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

  /// Formats time as `HH:mm` in 24-hour clock.
  String get formatTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Formats time as `hh:mm AM/PM` in 12-hour clock.
  String get formatTime12 {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Formats as `dd MMM yyyy, HH:mm`.
  String get formatDateTime => '$formatDate, $formatTime';

  // ---------------------------------------------------------------------------
  // Comparisons
  // ---------------------------------------------------------------------------

  /// Returns `true` if this [DateTime] is on today's date.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns `true` if this [DateTime] is on tomorrow's date.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Returns `true` if this [DateTime] is on yesterday's date.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns `true` if this [DateTime] is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Returns `true` if this [DateTime] is in the future.
  bool get isFuture => isAfter(DateTime.now());

  // ---------------------------------------------------------------------------
  // Boundary helpers
  // ---------------------------------------------------------------------------

  /// Returns a new [DateTime] representing the first moment of this day
  /// (midnight, `00:00:00.000`).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns a new [DateTime] representing the last moment of this day
  /// (`23:59:59.999`).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns a new [DateTime] representing the first day of this month.
  DateTime get startOfMonth => DateTime(year, month);

  /// Returns a new [DateTime] representing the last day of this month.
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns a display label: `"Today"`, `"Tomorrow"`, or [formatDate].
  String get smartLabel {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isYesterday) return 'Yesterday';
    return formatDate;
  }
}
