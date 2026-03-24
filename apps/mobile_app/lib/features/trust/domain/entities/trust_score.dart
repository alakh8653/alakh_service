import 'package:equatable/equatable.dart';

class TrustScore extends Equatable {
  final double overall;
  final Map<String, double> components;
  final DateTime lastUpdated;
  final double trend;

  const TrustScore({
    required this.overall,
    required this.components,
    required this.lastUpdated,
    required this.trend,
  });

  double get reliability => components['reliability'] ?? 0;
  double get quality => components['quality'] ?? 0;
  double get responsiveness => components['responsiveness'] ?? 0;
  double get safety => components['safety'] ?? 0;

  @override
  List<Object?> get props => [overall, components, lastUpdated, trend];
}
