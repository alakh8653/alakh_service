/// Auth module for alakh_service applications.
///
/// Provides authentication state management, secure token storage, automatic
/// token refresh, a Dio interceptor, OTP support, and social sign-in stubs.
///
/// **Quick start**:
/// ```dart
/// import 'package:auth_module/auth_module.dart';
///
/// final storage = SecureAuthStorage();
/// final refresher = TokenRefresher(
///   refreshFn: (token) => myApi.refreshToken(token),
///   storage: storage,
/// );
/// final authManager = AuthManager(storage: storage, refresher: refresher);
///
/// // Add the interceptor to Dio:
/// dio.interceptors.add(AuthDioInterceptor(authManager));
///
/// // Listen to state changes:
/// authManager.stateStream.listen((state) { ... });
/// ```
library auth_module;

export 'src/auth_credentials.dart';
export 'src/auth_exceptions.dart';
export 'src/auth_interceptor.dart';
export 'src/auth_manager.dart';
export 'src/auth_state.dart';
export 'src/auth_storage.dart';
export 'src/auth_token.dart';
export 'src/otp_service.dart';
export 'src/social_auth_provider.dart';
export 'src/token_refresher.dart';
