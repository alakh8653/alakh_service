/// Navigation abstraction service.
///
/// Decouples business logic and non-widget code from BuildContext-based
/// navigation by wrapping a [GlobalKey<NavigatorState>] (or GoRouter) with
/// a clean service interface.
library navigation_service;

import 'package:flutter/material.dart';

/// Abstract interface for programmatic navigation.
///
/// Concrete implementations can wrap GoRouter, Navigator 1.0, or a mock
/// for testing.
abstract class NavigationService {
  /// Navigates to [routePath], optionally replacing the current route.
  Future<T?> navigateTo<T>(
    String routePath, {
    Object? extra,
    Map<String, String> pathParams = const {},
    Map<String, dynamic> queryParams = const {},
    bool replace = false,
  });

  /// Navigates to a named route.
  Future<T?> navigateToNamed<T>(
    String routeName, {
    Object? extra,
    Map<String, String> pathParams = const {},
    Map<String, dynamic> queryParams = const {},
    bool replace = false,
  });

  /// Pops the current route, optionally returning a [result].
  void pop<T>([T? result]);

  /// Pops all routes back to the root.
  void popToRoot();

  /// Returns `true` if the navigator can pop the current route.
  bool canPop();

  /// Replaces the entire navigation stack with [routePath].
  void replaceAll(String routePath, {Object? extra});
}

/// Default [NavigationService] implementation backed by a [GlobalKey<NavigatorState>].
///
/// Register this in your DI container and inject the [navigatorKey] into
/// your [MaterialApp] (or GoRouter):
///
/// ```dart
/// final navService = NavigatorKeyNavigationService();
///
/// MaterialApp(
///   navigatorKey: navService.navigatorKey,
///   ...
/// )
/// ```
class NavigatorKeyNavigationService implements NavigationService {
  NavigatorKeyNavigationService({GlobalKey<NavigatorState>? navigatorKey})
      : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();

  /// The key to attach to [MaterialApp.navigatorKey] or [GoRouter.navigatorKey].
  final GlobalKey<NavigatorState> navigatorKey;

  NavigatorState? get _navigator => navigatorKey.currentState;

  @override
  Future<T?> navigateTo<T>(
    String routePath, {
    Object? extra,
    Map<String, String> pathParams = const {},
    Map<String, dynamic> queryParams = const {},
    bool replace = false,
  }) async {
    final navigator = _navigator;
    if (navigator == null) return null;
    if (replace) {
      return navigator.pushReplacementNamed<T, void>(routePath, arguments: extra);
    }
    return navigator.pushNamed<T>(routePath, arguments: extra);
  }

  @override
  Future<T?> navigateToNamed<T>(
    String routeName, {
    Object? extra,
    Map<String, String> pathParams = const {},
    Map<String, dynamic> queryParams = const {},
    bool replace = false,
  }) =>
      navigateTo<T>(
        routeName,
        extra: extra,
        pathParams: pathParams,
        queryParams: queryParams,
        replace: replace,
      );

  @override
  void pop<T>([T? result]) => _navigator?.pop<T>(result);

  @override
  void popToRoot() =>
      _navigator?.popUntil((route) => route.isFirst);

  @override
  bool canPop() => _navigator?.canPop() ?? false;

  @override
  void replaceAll(String routePath, {Object? extra}) {
    _navigator?.pushNamedAndRemoveUntil<void>(
      routePath,
      (route) => false,
      arguments: extra,
    );
  }
}
