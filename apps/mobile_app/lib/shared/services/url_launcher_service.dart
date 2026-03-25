/// URL, phone, email, and maps launcher service.
library;

// TODO: Add `url_launcher` package to pubspec.yaml.

/// Launches URLs, phone calls, emails, and map locations.
///
/// ### Usage:
/// ```dart
/// await UrlLauncherService.instance.launchUrl('https://example.com');
/// await UrlLauncherService.instance.callPhone('+919876543210');
/// ```
class UrlLauncherService {
  UrlLauncherService._();
  static final UrlLauncherService instance = UrlLauncherService._();

  // ---------------------------------------------------------------------------
  // Web URL
  // ---------------------------------------------------------------------------

  /// Opens [url] in the default browser.
  ///
  /// Pass [inApp] = `true` to open in an in-app WebView (Android / iOS).
  Future<bool> launchUrl(String url, {bool inApp = false}) async {
    // TODO:
    // final uri = Uri.parse(url);
    // return launchUrl(uri,
    //   mode: inApp
    //     ? LaunchMode.inAppWebView
    //     : LaunchMode.externalApplication,
    // );
    throw UnimplementedError('Add url_launcher and implement.');
  }

  // ---------------------------------------------------------------------------
  // Phone
  // ---------------------------------------------------------------------------

  /// Opens the phone dialler with [phoneNumber] pre-filled.
  Future<bool> callPhone(String phoneNumber) async {
    final encoded = Uri.encodeComponent(phoneNumber);
    return launchUrl('tel:$encoded');
  }

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  /// Opens the default email client to compose a new message.
  Future<bool> sendEmail({
    required String to,
    String? subject,
    String? body,
  }) async {
    final params = StringBuffer('mailto:$to');
    final queryParts = <String>[];
    if (subject != null) queryParts.add('subject=${Uri.encodeComponent(subject)}');
    if (body != null) queryParts.add('body=${Uri.encodeComponent(body)}');
    if (queryParts.isNotEmpty) params.write('?${queryParts.join('&')}');
    return launchUrl(params.toString());
  }

  // ---------------------------------------------------------------------------
  // SMS
  // ---------------------------------------------------------------------------

  /// Opens the SMS app with [phoneNumber] and optional [message].
  Future<bool> sendSms(String phoneNumber, {String? message}) async {
    final encoded = Uri.encodeComponent(phoneNumber);
    final suffix = message != null
        ? '?body=${Uri.encodeComponent(message)}'
        : '';
    return launchUrl('sms:$encoded$suffix');
  }

  // ---------------------------------------------------------------------------
  // Maps
  // ---------------------------------------------------------------------------

  /// Opens Google Maps (or the default maps app) at [latitude], [longitude].
  Future<bool> openMaps(double latitude, double longitude, {String? label}) async {
    final query = label != null ? Uri.encodeComponent(label) : '$latitude,$longitude';
    return launchUrl('https://maps.google.com/?q=$query&ll=$latitude,$longitude');
  }

  /// Opens the maps app with directions from [origin] to [destination].
  Future<bool> openDirections({
    required double destLat,
    required double destLng,
    double? originLat,
    double? originLng,
  }) async {
    final origin =
        originLat != null ? 'origin=$originLat,$originLng&' : '';
    return launchUrl(
      'https://maps.google.com/?${origin}daddr=$destLat,$destLng',
    );
  }
}
