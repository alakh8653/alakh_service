import 'dart:math';

/// Exponential backoff strategy for WebSocket reconnection.
class ExponentialBackoff {
  final Duration initialDelay;
  final Duration maxDelay;
  final double multiplier;
  final double jitter;
  int _attempt = 0;
  final Random _random = Random();

  ExponentialBackoff({
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.multiplier = 2.0,
    this.jitter = 0.2,
  });

  Duration nextDelay() {
    final baseMs =
        initialDelay.inMilliseconds * pow(multiplier, _attempt);
    final cappedMs =
        baseMs.clamp(0, maxDelay.inMilliseconds).toDouble();
    final jitterMs = jitter > 0
        ? cappedMs * jitter * (_random.nextDouble() * 2 - 1)
        : 0.0;
    final totalMs =
        (cappedMs + jitterMs).clamp(0, maxDelay.inMilliseconds).round();
    _attempt++;
    return Duration(milliseconds: totalMs);
  }

  void reset() => _attempt = 0;
  int get attempt => _attempt;
}
