/// A sealed discriminated union representing either a successful value [T]
/// or a failure value [E].
///
/// Example:
/// ```dart
/// Result<int, String> divide(int a, int b) {
///   if (b == 0) return Failure('Division by zero');
///   return Success(a ~/ b);
/// }
/// ```
sealed class Result<T, E> {
  const Result();

  /// Returns `true` if this is a [Success].
  bool get isSuccess => this is Success<T, E>;

  /// Returns `true` if this is a [Failure].
  bool get isFailure => this is Failure<T, E>;

  /// Returns the success value, or `null` if this is a [Failure].
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  /// Returns the failure value, or `null` if this is a [Success].
  E? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  /// Transforms the success value using [transform], leaving failures untouched.
  Result<R, E> map<R>(R Function(T value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        Failure(:final error) => Failure(error),
      };

  /// Transforms the failure value using [transform], leaving successes untouched.
  Result<T, F> mapError<F>(F Function(E error) transform) => switch (this) {
        Success(:final value) => Success(value),
        Failure(:final error) => Failure(transform(error)),
      };

  /// Calls [onSuccess] on a [Success] or [onFailure] on a [Failure] and
  /// returns the result.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        Failure(:final error) => onFailure(error),
      };

  /// Returns the success value, or [defaultValue] if this is a [Failure].
  T getOrElse(T defaultValue) => switch (this) {
        Success(:final value) => value,
        Failure() => defaultValue,
      };

  /// Returns the success value, or the result of calling [orElse] if this
  /// is a [Failure].
  T getOrElseGet(T Function(E error) orElse) => switch (this) {
        Success(:final value) => value,
        Failure(:final error) => orElse(error),
      };

  @override
  String toString() => switch (this) {
        Success(:final value) => 'Success($value)',
        Failure(:final error) => 'Failure($error)',
      };
}

/// Represents a successful [Result] carrying a value of type [T].
final class Success<T, E> extends Result<T, E> {
  /// The successful value.
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      other is Success<T, E> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Represents a failed [Result] carrying an error of type [E].
final class Failure<T, E> extends Result<T, E> {
  /// The error describing the failure.
  final E error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      other is Failure<T, E> && other.error == error;

  @override
  int get hashCode => error.hashCode;
}
