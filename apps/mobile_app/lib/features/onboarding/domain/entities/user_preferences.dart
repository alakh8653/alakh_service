import 'package:equatable/equatable.dart';

/// Captures the preferences a user selects during onboarding.
class UserPreferences extends Equatable {
  /// Categories the user is interested in (e.g. 'Plumbing', 'Cleaning').
  final List<String> selectedCategories;

  /// An optional broad location string (state / region).
  final String? preferredLocation;

  /// An optional city name for more precise matching.
  final String? preferredCity;

  /// Whether the user opted in to push notifications.
  final bool notificationsEnabled;

  const UserPreferences({
    required this.selectedCategories,
    this.preferredLocation,
    this.preferredCity,
    this.notificationsEnabled = true,
  });

  /// Returns a copy with the given fields replaced.
  UserPreferences copyWith({
    List<String>? selectedCategories,
    String? preferredLocation,
    String? preferredCity,
    bool? notificationsEnabled,
  }) {
    return UserPreferences(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      preferredCity: preferredCity ?? this.preferredCity,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        selectedCategories,
        preferredLocation,
        preferredCity,
        notificationsEnabled,
      ];
}
