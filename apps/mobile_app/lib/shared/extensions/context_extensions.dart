/// [BuildContext] extensions for theme, media query, navigation and snackbar.
library;

import 'package:flutter/material.dart';

/// Convenience getters and helpers on [BuildContext].
extension ContextExtensions on BuildContext {
  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------

  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current colour scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The current text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Whether the current theme is dark.
  bool get isDarkMode =>
      Theme.of(this).brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // Media Query
  // ---------------------------------------------------------------------------

  /// The full [MediaQueryData] for this context.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// The logical size of the screen.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// The screen width in logical pixels.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The screen height in logical pixels.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Safe-area padding (e.g. notch, status bar).
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  /// System view insets (e.g. keyboard height).
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// Returns `true` when the software keyboard is visible.
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;

  /// Device pixel ratio.
  double get pixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// `true` if the device is in landscape orientation.
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// The nearest [NavigatorState].
  NavigatorState get navigator => Navigator.of(this);

  /// Pops the current route.
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Pushes a named route.
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);

  /// Pushes a named route and removes all routes below it.
  Future<T?> pushNamedAndRemoveAll<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamedAndRemoveUntil<T>(
        routeName,
        (route) => false,
        arguments: arguments,
      );

  /// Pushes [widget] as a new [MaterialPageRoute].
  Future<T?> push<T>(Widget widget) => Navigator.of(this).push<T>(
        MaterialPageRoute<T>(builder: (_) => widget),
      );

  // ---------------------------------------------------------------------------
  // Focus
  // ---------------------------------------------------------------------------

  /// Unfocuses the current focus node (hides keyboard).
  void unfocus() => FocusScope.of(this).unfocus();

  // ---------------------------------------------------------------------------
  // SnackBar
  // ---------------------------------------------------------------------------

  /// Shows a simple informational [SnackBar].
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
        ),
      );
  }

  /// Shows a success-coloured [SnackBar].
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
        ),
      );
  }

  /// Shows an error-coloured [SnackBar].
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(this).colorScheme.error,
        ),
      );
  }
}
