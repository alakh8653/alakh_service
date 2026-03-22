/// Clipboard read/write service.
library;

import 'package:flutter/services.dart';

/// Provides clipboard access via [Clipboard].
///
/// ### Usage:
/// ```dart
/// await ClipboardService.instance.copy('Hello');
/// final text = await ClipboardService.instance.paste();
/// ```
class ClipboardService {
  ClipboardService._();
  static final ClipboardService instance = ClipboardService._();

  /// Writes [text] to the system clipboard.
  Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  /// Reads the current text from the system clipboard.
  ///
  /// Returns `null` when the clipboard is empty or contains non-text data.
  Future<String?> paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  /// Returns `true` if the clipboard currently holds text data.
  Future<bool> hasText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text?.isNotEmpty == true;
  }

  /// Clears the clipboard by writing an empty string.
  Future<void> clear() => Clipboard.setData(const ClipboardData(text: ''));
}
