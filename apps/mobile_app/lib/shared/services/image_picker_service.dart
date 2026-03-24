/// Image and video picker abstraction (camera and gallery).
library;

// TODO: Add `image_picker` package to pubspec.yaml.

/// The source from which media should be picked.
enum MediaSource {
  /// Device camera (photo or video capture).
  camera,

  /// Device photo gallery / library.
  gallery,
}

/// Metadata about a picked media file.
class PickedMedia {
  const PickedMedia({
    required this.path,
    required this.name,
    required this.mimeType,
    this.sizeBytes,
  });

  /// Absolute path to the file on the device.
  final String path;

  /// File name including extension.
  final String name;

  /// MIME type (e.g. `image/jpeg`, `video/mp4`).
  final String mimeType;

  /// File size in bytes (if available).
  final int? sizeBytes;

  /// Returns `true` when this is an image file.
  bool get isImage => mimeType.startsWith('image/');

  /// Returns `true` when this is a video file.
  bool get isVideo => mimeType.startsWith('video/');
}

/// Abstracts image and video picking from camera or gallery.
///
/// ### Usage:
/// ```dart
/// final media = await ImagePickerService.instance.pickImage(MediaSource.gallery);
/// if (media != null) uploadImage(media.path);
/// ```
class ImagePickerService {
  ImagePickerService._();
  static final ImagePickerService instance = ImagePickerService._();

  // TODO: final _picker = ImagePicker();

  /// Picks a single image from [source].
  ///
  /// Returns `null` if the user cancels.
  Future<PickedMedia?> pickImage(
    MediaSource source, {
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    // TODO:
    // final source = source == MediaSource.camera
    //     ? ImageSource.camera
    //     : ImageSource.gallery;
    // final file = await _picker.pickImage(
    //   source: source,
    //   imageQuality: imageQuality,
    //   maxWidth: maxWidth,
    //   maxHeight: maxHeight,
    // );
    // if (file == null) return null;
    // return PickedMedia(
    //   path: file.path,
    //   name: file.name,
    //   mimeType: file.mimeType ?? 'image/jpeg',
    //   sizeBytes: await file.length(),
    // );
    throw UnimplementedError('Add image_picker and implement.');
  }

  /// Picks a single video from [source].
  Future<PickedMedia?> pickVideo(MediaSource source) async {
    // TODO: Similar to pickImage but with _picker.pickVideo.
    throw UnimplementedError('Add image_picker and implement.');
  }

  /// Picks multiple images from the gallery.
  Future<List<PickedMedia>> pickMultipleImages({int imageQuality = 85}) async {
    // TODO: Use _picker.pickMultiImage.
    throw UnimplementedError('Add image_picker and implement.');
  }
}
