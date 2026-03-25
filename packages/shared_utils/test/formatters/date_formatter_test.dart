import 'package:test/test.dart';
import 'package:shared_utils/shared_utils.dart';

void main() {
  group('DateFormatter.formatDate', () {
    test('returns dd MMM yyyy format', () {
      final date = DateTime(2024, 1, 5);
      expect(DateFormatter.formatDate(date), '05 Jan 2024');
    });

    test('zero-pads single-digit day', () {
      final date = DateTime(2023, 12, 3);
      expect(DateFormatter.formatDate(date), '03 Dec 2023');
    });
  });

  group('DateFormatter.formatTime', () {
    test('formats time as hh:mm a', () {
      final date = DateTime(2024, 1, 5, 9, 30);
      expect(DateFormatter.formatTime(date), '09:30 AM');
    });

    test('formats PM correctly', () {
      final date = DateTime(2024, 1, 5, 14, 5);
      expect(DateFormatter.formatTime(date), '02:05 PM');
    });
  });

  group('DateFormatter.formatDuration', () {
    test('seconds only', () {
      expect(DateFormatter.formatDuration(const Duration(seconds: 45)), '45s');
    });

    test('minutes and seconds', () {
      expect(
        DateFormatter.formatDuration(const Duration(minutes: 3, seconds: 20)),
        '3m 20s',
      );
    });

    test('minutes only', () {
      expect(
        DateFormatter.formatDuration(const Duration(minutes: 5)),
        '5m',
      );
    });

    test('hours and minutes', () {
      expect(
        DateFormatter.formatDuration(const Duration(hours: 2, minutes: 5)),
        '2h 5m',
      );
    });

    test('hours only', () {
      expect(
        DateFormatter.formatDuration(const Duration(hours: 3)),
        '3h',
      );
    });
  });

  group('DateFormatter.timeAgo', () {
    test('just now for < 60 seconds', () {
      final recent = DateTime.now().subtract(const Duration(seconds: 30));
      expect(DateFormatter.timeAgo(recent), 'just now');
    });

    test('minutes ago', () {
      final twoMinsAgo = DateTime.now().subtract(const Duration(minutes: 2));
      expect(DateFormatter.timeAgo(twoMinsAgo), '2 minutes ago');
    });

    test('1 minute ago is singular', () {
      final oneMinAgo = DateTime.now().subtract(const Duration(minutes: 1));
      expect(DateFormatter.timeAgo(oneMinAgo), '1 minute ago');
    });

    test('hours ago', () {
      final threeHoursAgo = DateTime.now().subtract(const Duration(hours: 3));
      expect(DateFormatter.timeAgo(threeHoursAgo), '3 hours ago');
    });

    test('1 hour ago is singular', () {
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
      expect(DateFormatter.timeAgo(oneHourAgo), '1 hour ago');
    });

    test('yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(hours: 25));
      expect(DateFormatter.timeAgo(yesterday), 'yesterday');
    });

    test('days ago', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(DateFormatter.timeAgo(threeDaysAgo), '3 days ago');
    });

    test('older than 7 days returns formatted date', () {
      final old = DateTime(2020, 6, 15);
      expect(DateFormatter.timeAgo(old), '15 Jun 2020');
    });
  });
}
