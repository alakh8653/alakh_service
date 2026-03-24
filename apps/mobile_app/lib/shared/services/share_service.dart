/// Content sharing service (share text, images, links).
library;

// TODO: Add `share_plus` package to pubspec.yaml.

/// Abstracts the platform share sheet.
///
/// ### Usage:
/// ```dart
/// await ShareService.instance.shareText(
///   'Check out this shop!',
///   subject: 'Great find',
/// );
/// ```
class ShareService {
  ShareService._();
  static final ShareService instance = ShareService._();

  /// Shares plain text via the platform share sheet.
  Future<void> shareText(
    String text, {
    String? subject,
  }) async {
    // TODO: await Share.share(text, subject: subject);
    throw UnimplementedError(
      'ShareService.shareText: Add share_plus and implement.',
    );
  }

  /// Shares a URL with an optional title.
  Future<void> shareUrl(
    String url, {
    String? title,
  }) async {
    final text = title != null ? '$title\n$url' : url;
    await shareText(text, subject: title);
  }

  /// Shares one or more files (images, documents) via the platform share
  /// sheet.
  ///
  /// [filePaths] must be absolute paths to files on the device.
  Future<void> shareFiles(
    List<String> filePaths, {
    String? text,
    String? subject,
  }) async {
    // TODO:
    // final xFiles = filePaths.map((p) => XFile(p)).toList();
    // await Share.shareXFiles(xFiles, text: text, subject: subject);
    throw UnimplementedError(
      'ShareService.shareFiles: Add share_plus and implement.',
    );
  }
}
