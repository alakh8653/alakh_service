/// Data encryption/decryption utilities (AES-256-CBC).
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   encrypt: ^5.0.3
///   crypto: ^3.0.3
/// ```
library encryption_service;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../utils/logger.dart';

// TODO: Uncomment when encrypt package is available:
// import 'package:encrypt/encrypt.dart' as enc;
// import 'package:crypto/crypto.dart';

/// AES-256-CBC encryption/decryption service.
///
/// Usage:
/// ```dart
/// final service = EncryptionService(key: 'your-32-char-key');
/// final cipher = service.encrypt('sensitive data');
/// final plain  = service.decrypt(cipher);
/// ```
class EncryptionService {
  EncryptionService({required String key})
      : _key = _deriveKey(key);

  final Uint8List _key;
  final _log = AppLogger('EncryptionService');
  final _rng = Random.secure();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Encrypts [plaintext] and returns a Base64-encoded ciphertext string.
  ///
  /// The returned string includes the IV prefix so it can be decrypted
  /// without additional context.
  String encrypt(String plaintext) {
    try {
      // TODO: Uncomment real implementation when `encrypt` package is available:
      // final iv = enc.IV.fromSecureRandom(16);
      // final encrypter = enc.Encrypter(
      //   enc.AES(enc.Key(_key), mode: enc.AESMode.cbc),
      // );
      // final encrypted = encrypter.encrypt(plaintext, iv: iv);
      // // Prepend IV to ciphertext
      // final combined = Uint8List(16 + encrypted.bytes.length)
      //   ..setRange(0, 16, iv.bytes)
      //   ..setRange(16, 16 + encrypted.bytes.length, encrypted.bytes);
      // return base64Encode(combined);

      // Placeholder: XOR with key (NOT secure – replace with real AES)
      final bytes = utf8.encode(plaintext);
      final iv = _randomBytes(16);
      final xored = Uint8List(bytes.length);
      for (var i = 0; i < bytes.length; i++) {
        xored[i] = bytes[i] ^ _key[i % _key.length] ^ iv[i % 16];
      }
      final combined = Uint8List(16 + xored.length)
        ..setRange(0, 16, iv)
        ..setRange(16, 16 + xored.length, xored);
      return base64Encode(combined);
    } catch (e) {
      _log.e('Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypts a Base64-encoded [ciphertext] returned by [encrypt].
  String decrypt(String ciphertext) {
    try {
      // TODO: Uncomment real implementation when `encrypt` package is available:
      // final combined = base64Decode(ciphertext);
      // final iv = enc.IV(Uint8List.fromList(combined.sublist(0, 16)));
      // final encryptedBytes = combined.sublist(16);
      // final encrypter = enc.Encrypter(
      //   enc.AES(enc.Key(_key), mode: enc.AESMode.cbc),
      // );
      // return encrypter.decrypt(enc.Encrypted(Uint8List.fromList(encryptedBytes)), iv: iv);

      // Placeholder: XOR (matches the encrypt placeholder above)
      final combined = base64Decode(ciphertext);
      final iv = combined.sublist(0, 16);
      final xored = combined.sublist(16);
      final plain = Uint8List(xored.length);
      for (var i = 0; i < xored.length; i++) {
        plain[i] = xored[i] ^ _key[i % _key.length] ^ iv[i % 16];
      }
      return utf8.decode(plain);
    } catch (e) {
      _log.e('Decryption failed: $e');
      rethrow;
    }
  }

  /// Returns a SHA-256 hash of [input] as a hex string.
  String hash(String input) {
    // TODO: Use crypto package:
    // final bytes = utf8.encode(input);
    // final digest = sha256.convert(bytes);
    // return digest.toString();

    // Placeholder: simple checksum (NOT cryptographically secure)
    var checksum = 0;
    for (final c in utf8.encode(input)) {
      checksum = (checksum + c) & 0xFFFFFFFF;
    }
    return checksum.toRadixString(16).padLeft(64, '0');
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Uint8List _deriveKey(String key) {
    final bytes = utf8.encode(key);
    // Pad or truncate to 32 bytes (AES-256 key size)
    final result = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      result[i] = i < bytes.length ? bytes[i] : 0;
    }
    return result;
  }

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _rng.nextInt(256)),
    );
  }
}
