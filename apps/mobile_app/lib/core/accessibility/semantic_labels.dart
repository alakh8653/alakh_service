/// Semantic label constants for screen readers.
library semantic_labels;

/// String constants used as [Semantics.label] values throughout the app.
///
/// Centralising them here makes it easy to:
/// - Keep labels consistent across the app.
/// - Update wording without hunting through widget trees.
/// - Localise labels in the future.
abstract final class SemanticLabels {
  SemanticLabels._();

  // ── Navigation ────────────────────────────────────────────────────────────

  static const String backButton = 'Go back';
  static const String closeButton = 'Close';
  static const String menuButton = 'Open menu';
  static const String searchButton = 'Search';
  static const String notificationsButton = 'Notifications';
  static const String profileButton = 'Profile';

  // ── Auth ──────────────────────────────────────────────────────────────────

  static const String loginButton = 'Log in';
  static const String registerButton = 'Create account';
  static const String logoutButton = 'Log out';
  static const String forgotPasswordButton = 'Forgot password';
  static const String showPasswordButton = 'Show password';
  static const String hidePasswordButton = 'Hide password';

  // ── Inputs ────────────────────────────────────────────────────────────────

  static const String emailField = 'Email address';
  static const String passwordField = 'Password';
  static const String phoneField = 'Phone number';
  static const String otpField = 'One-time password';
  static const String searchField = 'Search field';
  static const String clearInputButton = 'Clear input';

  // ── Discovery ─────────────────────────────────────────────────────────────

  static const String shopCard = 'Shop card';
  static const String shopRating = 'Shop rating';
  static const String shopDistance = 'Shop distance';
  static const String viewShopButton = 'View shop details';
  static const String favoriteButton = 'Mark as favourite';
  static const String unfavoriteButton = 'Remove from favourites';

  // ── Booking ───────────────────────────────────────────────────────────────

  static const String bookNowButton = 'Book now';
  static const String cancelBookingButton = 'Cancel booking';
  static const String rescheduleButton = 'Reschedule booking';
  static const String bookingStatusBadge = 'Booking status';

  // ── Queue ─────────────────────────────────────────────────────────────────

  static const String joinQueueButton = 'Join queue';
  static const String leaveQueueButton = 'Leave queue';
  static const String queuePositionLabel = 'Your queue position';
  static const String estimatedWaitLabel = 'Estimated wait time';

  // ── Payment ───────────────────────────────────────────────────────────────

  static const String payButton = 'Pay now';
  static const String selectPaymentMethodButton = 'Select payment method';
  static const String paymentStatusLabel = 'Payment status';

  // ── Media ─────────────────────────────────────────────────────────────────

  static const String avatarImage = 'Profile picture';
  static const String shopImage = 'Shop image';
  static const String loadingIndicator = 'Loading';
  static const String errorImage = 'Image failed to load';

  // ── Rating / reviews ──────────────────────────────────────────────────────

  static const String starRating = 'Star rating';
  static const String submitReviewButton = 'Submit review';

  // ── Misc ──────────────────────────────────────────────────────────────────

  static const String refreshButton = 'Refresh';
  static const String retryButton = 'Retry';
  static const String shareButton = 'Share';
  static const String copyButton = 'Copy to clipboard';
  static const String expandButton = 'Expand';
  static const String collapseButton = 'Collapse';

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Generates a screen-reader label for a list item at [index] of [total].
  static String listItem(String item, int index, int total) =>
      '$item, item ${index + 1} of $total';

  /// Generates a label for a tab at [index] of [total].
  static String tab(String label, int index, int total) =>
      '$label tab, ${index + 1} of $total';
}
