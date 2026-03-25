/// Authentication service used by the presentation layer.
library;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../errors/shop_error_handler.dart';
import '../errors/shop_exceptions.dart';
import '../network/shop_api_client.dart';
import '../network/shop_api_endpoints.dart';
import 'shop_session_manager.dart';

/// Provides high-level authentication operations backed by [ShopApiClient]
/// and [ShopSessionManager].
class ShopAuthService {
  /// Creates a [ShopAuthService].
  ShopAuthService({
    required ShopApiClient apiClient,
    required ShopSessionManager sessionManager,
  })  : _apiClient = apiClient,
        _sessionManager = sessionManager;

  final ShopApiClient _apiClient;
  final ShopSessionManager _sessionManager;

  // -------------------------------------------------------------------------
  // Login
  // -------------------------------------------------------------------------

  /// Authenticates [email] and [password] against the server.
  ///
  /// On success stores the returned tokens and returns [Right(true)].
  /// On failure returns a [Left] containing a typed [Failure].
  Future<Either<Failure, bool>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ShopApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data == null) {
        return Left(ServerFailure(message: 'Empty response from server.'));
      }

      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final shopId = data['shop_id'] as String?;

      if (accessToken == null || refreshToken == null) {
        return Left(
          ServerFailure(message: 'Invalid token response from server.'),
        );
      }

      await _sessionManager.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      if (shopId != null) {
        await _sessionManager.saveShopId(shopId);
      }

      return const Right(true);
    } on DioException catch (e) {
      final exception = e.error is Exception
          ? e.error! as Exception
          : ServerException(message: e.message ?? 'Unknown error.');
      return Left(ShopErrorHandler.handleException(exception));
    } on Exception catch (e) {
      return Left(ShopErrorHandler.handleException(e));
    }
  }

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------

  /// Invalidates the server-side session and clears local token storage.
  ///
  /// The local session is cleared even if the server call fails.
  Future<void> logout() async {
    try {
      await _apiClient.post<void>(ShopApiEndpoints.logout);
    } catch (_) {
      // Best-effort – always clear local session.
    } finally {
      await _sessionManager.clearSession();
    }
  }

  // -------------------------------------------------------------------------
  // Token refresh
  // -------------------------------------------------------------------------

  /// Requests a new access token using the stored refresh token.
  ///
  /// Returns [Right(true)] on success or a [Left] [Failure] on error.
  Future<Either<Failure, bool>> refreshToken() async {
    try {
      final storedRefreshToken = await _sessionManager.getRefreshToken();
      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        return Left(AuthFailure(message: 'No refresh token available.'));
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        ShopApiEndpoints.refreshToken,
        data: {'refresh_token': storedRefreshToken},
      );

      final data = response.data;
      final newAccess = data?['access_token'] as String?;
      final newRefresh = data?['refresh_token'] as String?;

      if (newAccess == null) {
        return Left(AuthFailure(message: 'Token refresh returned no token.'));
      }

      await _sessionManager.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh ?? storedRefreshToken,
      );

      return const Right(true);
    } on DioException catch (e) {
      await _sessionManager.clearSession();
      final exception = e.error is Exception
          ? e.error! as Exception
          : AuthException(
              message: e.message ?? 'Token refresh failed.',
              statusCode: e.response?.statusCode,
            );
      return Left(ShopErrorHandler.handleException(exception));
    } on Exception catch (e) {
      return Left(ShopErrorHandler.handleException(e));
    }
  }

  // -------------------------------------------------------------------------
  // Current user
  // -------------------------------------------------------------------------

  /// Fetches the profile of the currently authenticated user.
  ///
  /// Returns the raw JSON map on success or a [Left] [Failure] on error.
  Future<Either<Failure, Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ShopApiEndpoints.me);
      final data = response.data;
      if (data == null) {
        return Left(ServerFailure(message: 'No user data returned.'));
      }
      return Right(data);
    } on DioException catch (e) {
      final exception = e.error is Exception
          ? e.error! as Exception
          : ServerException(
              message: e.message ?? 'Failed to fetch user.',
              statusCode: e.response?.statusCode,
            );
      return Left(ShopErrorHandler.handleException(exception));
    } on Exception catch (e) {
      return Left(ShopErrorHandler.handleException(e));
    }
  }
}
