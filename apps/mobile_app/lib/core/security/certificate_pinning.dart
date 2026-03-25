/// SSL certificate pinning configuration.
///
/// Prevents MITM attacks by rejecting TLS connections whose server certificate
/// does not match the pinned public-key hash(es).
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   dio: ^5.4.0
///   dio_certificate_pinning: ^4.0.0   # or http_certificate_pinning
/// ```
library certificate_pinning;

import '../utils/logger.dart';

// TODO: Uncomment when packages are available:
// import 'package:dio/dio.dart';
// import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

/// Certificate pinning configuration for the AlakhService API.
///
/// The [pinnedCertificateHashes] list contains the expected SHA-256 fingerprints
/// (in hex, without colons) of the server's leaf or intermediate certificates.
///
/// Rotate these values whenever the server's certificate is renewed.
abstract final class CertificatePinning {
  CertificatePinning._();

  static final _log = AppLogger('CertificatePinning');

  // ── Pinned hashes ─────────────────────────────────────────────────────────

  /// SHA-256 fingerprints of the pinned server certificates.
  ///
  /// TODO: Replace with the real certificate fingerprints for your domain.
  ///
  /// How to get the fingerprint:
  /// ```bash
  /// openssl s_client -connect api.example.com:443 | \
  ///   openssl x509 -pubkey -noout | \
  ///   openssl pkey -pubin -outform der | \
  ///   openssl dgst -sha256 -binary | \
  ///   openssl enc -base64
  /// ```
  static const List<String> pinnedCertificateHashes = [
    // TODO: Add real certificate hashes before deploying to production
    // 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // primary
    // 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // backup
  ];

  // ── Dio interceptor ───────────────────────────────────────────────────────

  /// Returns a Dio [HttpClientAdapter] with certificate pinning enabled.
  ///
  /// Attach to Dio before making any requests:
  /// ```dart
  /// dio.httpClientAdapter = CertificatePinning.buildDioAdapter();
  /// ```
  ///
  /// TODO: Uncomment when dio_certificate_pinning is available.
  // static HttpClientAdapter buildDioAdapter() {
  //   return CertificatePinningAdapter(
  //     allowedSHAFingerprints: pinnedCertificateHashes,
  //   );
  // }

  /// Logs a warning if no certificate hashes are configured.
  ///
  /// Call at app startup to detect misconfiguration early.
  static void assertConfigured() {
    if (pinnedCertificateHashes.isEmpty) {
      _log.w(
        'CertificatePinning: No certificate hashes configured! '
        'Add real hashes to pinnedCertificateHashes before release.',
      );
    } else {
      _log.i(
        'CertificatePinning: ${pinnedCertificateHashes.length} '
        'certificate hash(es) pinned.',
      );
    }
  }

  // ── Platform-native pinning ────────────────────────────────────────────────

  /// The domain to pin (used for Android network security config and iOS ATS).
  ///
  /// TODO: Update for your API domain.
  static const String pinnedDomain = 'api.alakhservice.com';

  /// Content for `android/app/src/main/res/xml/network_security_config.xml`.
  ///
  /// Paste this file and reference it from `AndroidManifest.xml`:
  /// ```xml
  /// <application
  ///   android:networkSecurityConfig="@xml/network_security_config"
  ///   ...>
  /// ```
  static const String androidNetworkSecurityConfig = '''
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config>
        <domain includeSubdomains="true">$pinnedDomain</domain>
        <pin-set expiration="2026-01-01">
            <!-- TODO: Replace with real SHA-256 Base64 pin -->
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
            <!-- Backup pin -->
            <pin digest="SHA-256">BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
''';
}
