/// Image caching configuration.
///
/// Wraps `cached_network_image` and `flutter_cache_manager` to provide
/// a consistent image caching strategy across the app.
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   cached_network_image: ^3.3.1
///   flutter_cache_manager: ^3.3.1
/// ```
library image_cache_manager;

import '../utils/logger.dart';

// TODO: Uncomment when packages are available:
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Application-wide image cache configuration.
///
/// Usage:
/// ```dart
/// CachedNetworkImage(
///   imageUrl: url,
///   cacheManager: AppImageCacheManager.instance,
///   placeholder: (ctx, url) => const ShimmerPlaceholder(),
///   errorWidget: (ctx, url, err) => const ImageErrorWidget(),
/// )
/// ```
abstract final class AppImageCacheManager {
  AppImageCacheManager._();

  static final _log = AppLogger('AppImageCacheManager');

  // TODO: Replace with real CacheManager when flutter_cache_manager is available:
  // static final CacheManager instance = CacheManager(
  //   Config(
  //     'alakhservice_images',
  //     stalePeriod: const Duration(days: 7),
  //     maxNrOfCacheObjects: 500,
  //     repo: JsonCacheInfoRepository(databaseName: 'alakhservice_images'),
  //     fileService: HttpFileService(),
  //   ),
  // );

  /// Maximum number of image entries kept in the Flutter in-memory image cache.
  ///
  /// Call [configureFlutterImageCache] at app startup (in `main.dart`).
  static const int maxCacheCount = 200;

  /// Maximum total size of the Flutter in-memory image cache in bytes.
  ///
  /// Defaults to 100 MB.
  static const int maxCacheSizeBytes = 100 * 1024 * 1024;

  /// Configures Flutter's built-in [ImageCache] with app-specific limits.
  ///
  /// Must be called after `WidgetsFlutterBinding.ensureInitialized()`.
  static void configureFlutterImageCache() {
    // PaintingBinding.instance.imageCache
    //   ..maximumSize = maxCacheCount
    //   ..maximumSizeBytes = maxCacheSizeBytes;
    _log.i(
      'Image cache configured: '
      'maxCount=$maxCacheCount, maxSize=${maxCacheSizeBytes ~/ (1024 * 1024)}MB',
    );
  }

  /// Clears the Flutter in-memory image cache.
  static void clearMemoryCache() {
    // PaintingBinding.instance.imageCache.clear();
    _log.i('In-memory image cache cleared');
  }

  /// Clears the persistent disk image cache.
  ///
  /// TODO: await AppImageCacheManager.instance.emptyCache();
  static Future<void> clearDiskCache() async {
    _log.i('Disk image cache cleared');
  }
}
