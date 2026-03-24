import 'package:shared_preferences/shared_preferences.dart';

/// Manages per-category notification preferences for the current user.
///
/// Preferences are persisted locally via [SharedPreferences] and should be
/// synced to the backend whenever they change.
class NotificationPreferences {
  NotificationPreferences._();
  static final NotificationPreferences instance = NotificationPreferences._();

  static const String _prefix = 'notif_pref_';

  // Preference keys
  static const String bookings = 'bookings';
  static const String chat = 'chat';
  static const String queue = 'queue';
  static const String payments = 'payments';
  static const String promotions = 'promotions';
  static const String system = 'system';

  static const List<String> allCategories = [
    bookings,
    chat,
    queue,
    payments,
    promotions,
    system,
  ];

  late SharedPreferences _prefs;

  /// Loads preferences from local storage. Must be called before any reads/writes.
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Returns whether the given notification [category] is enabled.
  ///
  /// Defaults to `true` for all categories except [promotions] (which defaults to `false`).
  bool isEnabled(String category) {
    final defaultValue = category != promotions;
    return _prefs.getBool('$_prefix$category') ?? defaultValue;
  }

  /// Enables or disables the given notification [category].
  Future<void> setEnabled(String category, {required bool enabled}) async {
    await _prefs.setBool('$_prefix$category', enabled);
  }

  /// Returns a map of all category preferences keyed by category name.
  Map<String, bool> getAllPreferences() {
    return {
      for (final category in allCategories) category: isEnabled(category),
    };
  }

  /// Resets all preferences to their default values.
  Future<void> resetToDefaults() async {
    for (final category in allCategories) {
      await _prefs.remove('$_prefix$category');
    }
  }
}
