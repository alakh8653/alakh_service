/// Mixin that provides loading / error / data state management.
library;

import 'package:flutter/foundation.dart';

/// Attach to a [ChangeNotifier] or [StatefulWidget] state to manage async
/// operation states without boilerplate.
///
/// ### Usage with [ChangeNotifier]:
/// ```dart
/// class MyController extends ChangeNotifier with LoadingMixin {
///   Future<void> fetchData() async {
///     await runWithLoading(() async {
///       // ... fetch
///     });
///   }
/// }
/// ```
mixin LoadingMixin on ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  /// Whether an async operation is currently in progress.
  bool get isLoading => _isLoading;

  /// The most recent error message, or `null` when there is no error.
  String? get errorMessage => _errorMessage;

  /// Returns `true` when [errorMessage] is not null.
  bool get hasError => _errorMessage != null;

  /// Sets [isLoading] to `true` and clears any previous error.
  @protected
  void setLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Sets [isLoading] to `false`.
  @protected
  void setDone() {
    _isLoading = false;
    notifyListeners();
  }

  /// Marks a loading failure with [message] and stops the loading indicator.
  @protected
  void setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears the current error message.
  @protected
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Executes [operation], automatically managing loading state.
  ///
  /// If [operation] throws an exception, [onError] is called if provided,
  /// otherwise [setError] is called with the exception's `toString()`.
  Future<T?> runWithLoading<T>(
    Future<T> Function() operation, {
    void Function(Object error)? onError,
  }) async {
    setLoading();
    try {
      final result = await operation();
      setDone();
      return result;
    } catch (e) {
      if (onError != null) {
        onError(e);
        setDone();
      } else {
        setError(e.toString());
      }
      return null;
    }
  }
}
