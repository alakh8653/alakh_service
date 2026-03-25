import 'package:equatable/equatable.dart';

/// Represents a closed date/time interval from [start] to [end].
class DateRange extends Equatable {
  /// The inclusive start of the range.
  final DateTime start;

  /// The inclusive end of the range.
  final DateTime end;

  /// Creates a [DateRange].
  ///
  /// Throws [ArgumentError] if [start] is after [end].
  DateRange({required this.start, required this.end}) {
    if (start.isAfter(end)) {
      throw ArgumentError('start must not be after end');
    }
  }

  /// Creates a [DateRange] from a JSON map with ISO-8601 strings.
  factory DateRange.fromJson(Map<String, dynamic> json) => DateRange(
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
      );

  /// Converts this instance to a JSON map with ISO-8601 strings.
  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  /// Returns a copy with optionally overridden fields.
  DateRange copyWith({DateTime? start, DateTime? end}) => DateRange(
        start: start ?? this.start,
        end: end ?? this.end,
      );

  /// The total duration of this range.
  Duration get duration => end.difference(start);

  /// Returns `true` if [dateTime] falls within [start] (inclusive) and
  /// [end] (inclusive).
  bool contains(DateTime dateTime) =>
      !dateTime.isBefore(start) && !dateTime.isAfter(end);

  /// Returns `true` if this range overlaps with [other], including ranges
  /// that share an exact boundary point.
  bool overlaps(DateRange other) =>
      !start.isAfter(other.end) && !end.isBefore(other.start);

  @override
  List<Object?> get props => [start, end];

  @override
  String toString() => 'DateRange(start: $start, end: $end)';
}
