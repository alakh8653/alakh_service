import 'package:equatable/equatable.dart';

/// Represents a single step in the onboarding flow.
class OnboardingStep extends Equatable {
  /// Unique identifier for this step.
  final String id;

  /// Title displayed at the top of the step.
  final String title;

  /// Descriptive body text for the step.
  final String description;

  /// Asset path of the illustration shown on the step.
  final String imageAsset;

  /// Zero-based order index used to sort steps.
  final int order;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.order,
  });

  @override
  List<Object?> get props => [id, title, description, imageAsset, order];
}
