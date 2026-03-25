import '../../domain/entities/entities.dart';

/// Data-layer representation of [OnboardingStep] with JSON serialisation.
class OnboardingStepModel extends OnboardingStep {
  const OnboardingStepModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageAsset,
    required super.order,
  });

  /// Deserialises from a JSON map (e.g. API response or cached value).
  factory OnboardingStepModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStepModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageAsset: json['imageAsset'] as String,
      order: json['order'] as int,
    );
  }

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imageAsset': imageAsset,
        'order': order,
      };

  /// Returns a copy with the given fields replaced.
  OnboardingStepModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageAsset,
    int? order,
  }) {
    return OnboardingStepModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageAsset: imageAsset ?? this.imageAsset,
      order: order ?? this.order,
    );
  }

  /// Converts a domain entity to its model counterpart.
  factory OnboardingStepModel.fromEntity(OnboardingStep entity) {
    return OnboardingStepModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageAsset: entity.imageAsset,
      order: entity.order,
    );
  }
}
