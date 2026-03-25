/// Debounce utility for search / input handlers.
library debouncer;

import 'dart:async';

/// Delays invoking [action] until [duration] has elapsed since the last call.
///
/// Useful for rate-limiting expensive operations like search-as-you-type:
///
/// ```dart
/// final _debouncer = Debouncer(duration: Duration(milliseconds: 300));
///
/// void onSearchChanged(String query) {
///   _debouncer.run(() => _searchBloc.add(SearchQueryChanged(query)));
/// }
///
/// @override
/// void dispose() {
///   _debouncer.cancel();
///   super.dispose();
/// }
/// ```
class Debouncer {
  /// Creates a [Debouncer] that waits [duration] before calling the action.
  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// The wait duration after the last call before the action is invoked.
  final Duration duration;

  Timer? _timer;

  /// Whether there is a pending invocation.
  bool get isPending => _timer?.isActive ?? false;

  /// Schedules [action] to be called after [duration].
  ///
  /// If called again before [duration] has elapsed, the previous invocation
  /// is cancelled and the timer is reset.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancels any pending invocation without calling the action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels any pending invocation and releases the timer resource.
  void dispose() => cancel();
}

/// A throttle variant that guarantees at most one call per [duration].
///
/// Unlike [Debouncer], which delays until quiet, [Throttler] fires immediately
/// on the first call and ignores subsequent calls until [duration] elapses.
///
/// ```dart
/// final _throttler = Throttler(duration: Duration(seconds: 1));
///
/// void onScrollChanged() {
///   _throttler.run(() => _sendAnalyticsEvent());
/// }
/// ```
class Throttler {
  Throttler({this.duration = const Duration(seconds: 1)});

  final Duration duration;

  DateTime? _lastRun;

  /// Invokes [action] immediately if [duration] has elapsed since the last run.
  void run(void Function() action) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= duration) {
      _lastRun = now;
      action();
    }
  }

  /// Resets the throttle window.
  void reset() => _lastRun = null;
}
