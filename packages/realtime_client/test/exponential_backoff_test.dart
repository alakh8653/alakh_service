import 'package:realtime_client/realtime_client.dart';
import 'package:test/test.dart';

void main() {
  group('ExponentialBackoff', () {
    test('first delay equals initialDelay with no jitter', () {
      final b = ExponentialBackoff(
          initialDelay: const Duration(seconds: 1), jitter: 0.0);
      expect(b.nextDelay(), equals(const Duration(seconds: 1)));
    });

    test('delays increase', () {
      final b = ExponentialBackoff(
          initialDelay: const Duration(seconds: 1),
          maxDelay: const Duration(seconds: 60),
          multiplier: 2.0,
          jitter: 0.0);
      final d1 = b.nextDelay();
      final d2 = b.nextDelay();
      expect(d2.inMilliseconds, greaterThan(d1.inMilliseconds));
    });

    test('caps at maxDelay', () {
      final b = ExponentialBackoff(
          initialDelay: const Duration(seconds: 1),
          maxDelay: const Duration(seconds: 5),
          multiplier: 10.0,
          jitter: 0.0);
      for (int i = 0; i < 10; i++) {
        expect(b.nextDelay().inMilliseconds, lessThanOrEqualTo(5000));
      }
    });

    test('reset returns attempt to 0', () {
      final b = ExponentialBackoff(jitter: 0.0);
      b.nextDelay();
      b.nextDelay();
      b.reset();
      expect(b.attempt, 0);
    });
  });
}
