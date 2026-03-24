import 'package:equatable/equatable.dart';

/// The result returned by a successful social authentication sign-in.
class SocialAuthResult extends Equatable {
  /// The ID token issued by the social provider.
  final String idToken;

  /// The OAuth access token from the social provider, if available.
  final String? accessToken;

  /// The name of the social provider, e.g. `'google'` or `'apple'`.
  final String provider;

  /// The user's email as reported by the social provider.
  final String? email;

  /// The user's display name as reported by the social provider.
  final String? displayName;

  /// A URL pointing to the user's profile photo, if available.
  final String? photoUrl;

  const SocialAuthResult({
    required this.idToken,
    required this.provider,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props =>
      [idToken, accessToken, provider, email, displayName, photoUrl];
}

/// Abstract interface for a social (OAuth) sign-in provider.
///
/// Concrete implementations should inject the platform-specific SDK instance
/// (e.g. `google_sign_in`, `sign_in_with_apple`) from the consuming app layer
/// so that this package remains SDK-agnostic.
abstract class SocialAuthProvider {
  /// The canonical name of this provider, e.g. `'google'` or `'apple'`.
  String get providerName;

  /// Initiates the sign-in flow.
  ///
  /// Returns a [SocialAuthResult] on success, or `null` if the user cancelled.
  /// Throws a [SocialAuthException] on failure.
  Future<SocialAuthResult?> signIn();

  /// Signs out the user from the social provider session.
  Future<void> signOut();

  /// Returns `true` if the user currently has an active social provider
  /// session.
  Future<bool> isSignedIn();
}

/// Google Sign-In provider stub.
///
/// **Usage**: subclass or replace this in your app layer and inject a real
/// `GoogleSignIn` instance. This package intentionally does not depend on
/// `google_sign_in` to avoid forcing that dependency on all consumers.
///
/// ```dart
/// class MyGoogleAuthProvider extends GoogleAuthProvider {
///   final GoogleSignIn _googleSignIn;
///   MyGoogleAuthProvider(this._googleSignIn);
///
///   @override
///   Future<SocialAuthResult?> signIn() async {
///     final account = await _googleSignIn.signIn();
///     if (account == null) return null;
///     final auth = await account.authentication;
///     return SocialAuthResult(
///       provider: providerName,
///       idToken: auth.idToken!,
///       accessToken: auth.accessToken,
///       email: account.email,
///       displayName: account.displayName,
///       photoUrl: account.photoUrl,
///     );
///   }
/// }
/// ```
class GoogleAuthProvider implements SocialAuthProvider {
  @override
  String get providerName => 'google';

  @override
  Future<SocialAuthResult?> signIn() async {
    throw UnimplementedError(
      'GoogleAuthProvider.signIn() must be implemented in the app layer. '
      'Inject a GoogleSignIn instance and override this method.',
    );
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError(
      'GoogleAuthProvider.signOut() must be implemented in the app layer.',
    );
  }

  @override
  Future<bool> isSignedIn() async {
    throw UnimplementedError(
      'GoogleAuthProvider.isSignedIn() must be implemented in the app layer.',
    );
  }
}

/// Apple Sign-In provider stub.
///
/// **Usage**: subclass or replace this in your app layer and use the
/// `sign_in_with_apple` package. This package does not depend on
/// `sign_in_with_apple` to keep the dependency footprint minimal.
///
/// ```dart
/// class MyAppleAuthProvider extends AppleAuthProvider {
///   @override
///   Future<SocialAuthResult?> signIn() async {
///     final credential = await SignInWithApple.getAppleIDCredential(
///       scopes: [AppleIDAuthorizationScopes.email,
///                AppleIDAuthorizationScopes.fullName],
///     );
///     return SocialAuthResult(
///       provider: providerName,
///       idToken: credential.identityToken!,
///       email: credential.email,
///       displayName: [
///         credential.givenName,
///         credential.familyName,
///       ].whereType<String>().join(' '),
///     );
///   }
/// }
/// ```
class AppleAuthProvider implements SocialAuthProvider {
  @override
  String get providerName => 'apple';

  @override
  Future<SocialAuthResult?> signIn() async {
    throw UnimplementedError(
      'AppleAuthProvider.signIn() must be implemented in the app layer. '
      'Use the sign_in_with_apple package and override this method.',
    );
  }

  @override
  Future<void> signOut() async {
    // Apple does not provide a programmatic sign-out API; this is a no-op.
  }

  @override
  Future<bool> isSignedIn() async {
    throw UnimplementedError(
      'AppleAuthProvider.isSignedIn() must be implemented in the app layer.',
    );
  }
}
