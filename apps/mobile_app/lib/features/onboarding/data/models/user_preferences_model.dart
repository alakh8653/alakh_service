import '../../domain/entities/entities.dart';

/// Data-layer representation of [UserPreferences] with JSON serialisation.
class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    required super.selectedCategories,
    super.preferredLocation,
    super.preferredCity,
    super.notificationsEnabled,
  });

  /// Deserialises from a JSON map.
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      selectedCategories: List<String>.from(
        (json['selectedCategories'] as List<dynamic>?) ?? [],
      ),
      preferredLocation: json['preferredLocation'] as String?,
      preferredCity: json['preferredCity'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'selectedCategories': selectedCategories,
        'preferredLocation': preferredLocation,
        'preferredCity': preferredCity,
        'notificationsEnabled': notificationsEnabled,
      };

  /// Returns a copy with the given fields replaced.
  @override
  UserPreferencesModel copyWith({
    List<String>? selectedCategories,
    String? preferredLocation,
    String? preferredCity,
    bool? notificationsEnabled,
  }) {
    return UserPreferencesModel(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      preferredCity: preferredCity ?? this.preferredCity,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  /// Converts a domain entity to its model counterpart.
  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      selectedCategories: entity.selectedCategories,
      preferredLocation: entity.preferredLocation,
      preferredCity: entity.preferredCity,
      notificationsEnabled: entity.notificationsEnabled,
    );
  }
}
