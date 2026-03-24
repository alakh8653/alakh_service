/// Limits how frequently an action can be executed to at most once per
/// [interval].
///
/// Unlike a [Debouncer], a [Throttler] runs the action immediately on the
/// first call and then ignores subsequent calls until the interval has elapsed.
///
/// ```dart
/// final throttler = Throttler(interval: const Duration(milliseconds: 500));
///
/// // In a scroll listener:
/// throttler.run(() => handleScroll());
///
/// // Always dispose when no longer needed:
/// throttler.dispose();
/// ```
class Throttler {
  /// Creates a [Throttler] with the given [interval].
  Throttler({required this.interval});

  /// The minimum time between consecutive action executions.
  final Duration interval;

  DateTime? _lastRun;

  /// Executes [action] immediately if [interval] has elapsed since the last
  /// execution; otherwise the call is ignored.
  void run(void Function() action) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      _lastRun = now;
      action();
    }
  }

  /// Resets the throttle state and releases resources.
  ///
  /// The [Throttler] must not be used after [dispose] is called.
  void dispose() {
    _lastRun = null;
  }
}
