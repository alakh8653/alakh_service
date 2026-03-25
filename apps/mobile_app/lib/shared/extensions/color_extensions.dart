/// [Color] extension methods for manipulation and conversion.
library;

import 'dart:ui';

/// Color utility helpers.
extension ColorExtensions on Color {
  // ---------------------------------------------------------------------------
  // Darken / Lighten
  // ---------------------------------------------------------------------------

  /// Returns a darker version of this colour by [amount] (0.0–1.0).
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Returns a lighter version of this colour by [amount] (0.0–1.0).
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  // ---------------------------------------------------------------------------
  // Opacity
  // ---------------------------------------------------------------------------

  /// Returns a copy with [opacity] (0.0–1.0) applied.
  ///
  /// Shorthand for [withValues(alpha: opacity)] (Dart 3.x API).
  Color withOpacityValue(double opacity) =>
      withValues(alpha: opacity.clamp(0.0, 1.0));

  // ---------------------------------------------------------------------------
  // Hex conversion
  // ---------------------------------------------------------------------------

  /// Converts the colour to an `#RRGGBB` hex string.
  ///
  /// Pass [includeAlpha] = `true` to get `#AARRGGBB`.
  String toHex({bool includeAlpha = false}) {
    final r = (this.r * 255).round();
    final g = (this.g * 255).round();
    final b = (this.b * 255).round();
    final a = (this.a * 255).round();
    if (includeAlpha) {
      return '#${a.toRadixString(16).padLeft(2, '0')}'
          '${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    }
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  // ---------------------------------------------------------------------------
  // Contrast
  // ---------------------------------------------------------------------------

  /// Returns `true` if black text on this background meets WCAG AA contrast.
  ///
  /// Use to decide whether to display black or white text on this colour.
  bool get isLight {
    final luminance = computeLuminance();
    return luminance > 0.179;
  }

  /// Returns [Colors.black] if this colour is light, [Colors.white] otherwise.
  Color get contrastingTextColor =>
      isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
}

/// Static factory helpers for creating [Color] values.
abstract final class ColorFactory {
  /// Parses a hex string into a [Color].
  ///
  /// Accepts `#RRGGBB`, `#AARRGGBB`, `RRGGBB`, or `AARRGGBB` formats.
  ///
  /// Throws [FormatException] if the string is invalid.
  static Color fromHex(String hex) {
    var cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    if (cleaned.length != 8) {
      throw FormatException('Invalid hex colour: $hex');
    }
    final value = int.parse(cleaned, radix: 16);
    return Color(value);
  }

  /// Like [fromHex] but returns `null` instead of throwing on invalid input.
  static Color? tryFromHex(String? hex) {
    if (hex == null) return null;
    try {
      return fromHex(hex);
    } on FormatException {
      return null;
    }
  }
}
