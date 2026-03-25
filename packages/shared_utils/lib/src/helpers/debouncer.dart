import 'dart:async';

/// Delays execution of an action until [delay] has elapsed since the last call.
///
/// Useful for suppressing high-frequency events such as text-field changes.
///
/// ```dart
/// final debouncer = Debouncer(delay: const Duration(milliseconds: 300));
///
/// // In a text-field's onChanged callback:
/// debouncer.run(() => performSearch(query));
///
/// // Always dispose when no longer needed:
/// debouncer.dispose();
/// ```
class Debouncer {
  /// Creates a [Debouncer] with the given [delay].
  Debouncer({required this.delay});

  /// The minimum quiet period before the action is executed.
  final Duration delay;

  Timer? _timer;

  /// Schedules [action] to run after [delay] has elapsed with no further calls.
  ///
  /// Any pending invocation is cancelled first.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending action without executing it.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels any pending action and releases resources.
  ///
  /// The [Debouncer] must not be used after [dispose] is called.
  void dispose() => cancel();
}
