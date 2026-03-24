/// Deep link handling and parsing service.
library;

// TODO: Add `app_links` or `uni_links` package to pubspec.yaml.

import 'dart:async';

/// Represents a parsed deep link with its path and query parameters.
class DeepLink {
  const DeepLink({
    required this.uri,
    required this.path,
    this.queryParameters = const {},
  });

  /// The full URI that was received.
  final Uri uri;

  /// The path component (e.g. `/booking/123`).
  final String path;

  /// Decoded query parameters map.
  final Map<String, String> queryParameters;

  @override
  String toString() => 'DeepLink(path: $path, params: $queryParameters)';
}

/// Handles incoming deep links and app links.
///
/// ### Usage:
/// ```dart
/// final service = DeepLinkService.instance;
/// await service.init();
/// service.onDeepLink.listen((link) {
///   router.go(link.path);
/// });
/// ```
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final StreamController<DeepLink> _controller =
      StreamController<DeepLink>.broadcast();

  /// Stream of incoming deep links.
  Stream<DeepLink> get onDeepLink => _controller.stream;

  /// Initialises the deep link listener.
  ///
  /// Call this early in the app lifecycle (e.g. from `bootstrap.dart`).
  Future<void> init() async {
    // TODO: Subscribe to app_links / uni_links stream.
    // Example with app_links:
    // _appLinks = AppLinks();
    // _subscription = _appLinks.uriLinkStream.listen((uri) {
    //   _controller.add(_parse(uri));
    // });
    //
    // Also handle the initial link that launched the app:
    // final initialLink = await _appLinks.getInitialLink();
    // if (initialLink != null) _controller.add(_parse(initialLink));
  }

  /// Manually processes a URI string (useful for testing).
  void processLink(String rawUri) {
    final uri = Uri.tryParse(rawUri);
    if (uri != null) _controller.add(_parse(uri));
  }

  DeepLink _parse(Uri uri) => DeepLink(
        uri: uri,
        path: uri.path,
        queryParameters: uri.queryParameters,
      );

  /// Disposes the stream controller and cancels subscriptions.
  void dispose() {
    _controller.close();
  }
}
