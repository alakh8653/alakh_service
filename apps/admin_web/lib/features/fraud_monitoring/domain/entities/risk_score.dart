import 'package:equatable/equatable.dart';

/// Risk score entity for users and shops.
class RiskScore extends Equatable {
  final String entityId;
  final String entityType;
  final double overallScore;
  final Map<String, double> components;
  final List<String> signals;
  final DateTime calculatedAt;

  const RiskScore({
    required this.entityId,
    required this.entityType,
    required this.overallScore,
    required this.components,
    required this.signals,
    required this.calculatedAt,
  });

  @override
  List<Object> get props => [entityId, entityType, overallScore, calculatedAt];
}
