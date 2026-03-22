import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Abstract interface for remote authentication data source.
abstract class AuthRemoteDataSource {
  /// Authenticates a user via email and password.
  Future<AuthTokenModel> login(LoginRequestModel request);

  /// Registers a new user account.
  Future<UserModel> register(RegisterRequestModel request);

  /// Verifies an OTP code sent to a phone number.
  Future<AuthTokenModel> verifyOtp(OtpRequestModel request);

  /// Logs out the user on the server side.
  Future<void> logout();

  /// Refreshes the access token using the provided refresh token.
  Future<AuthTokenModel> refreshToken(String refreshToken);

  /// Authenticates via a social provider token.
  Future<AuthTokenModel> socialLogin(String provider, String token);

  /// Fetches the currently authenticated user's profile.
  Future<UserModel> getCurrentUser(String accessToken);
}

/// Concrete implementation of [AuthRemoteDataSource] using [http.Client].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  // TODO: Replace with your actual API base URL (from environment config).
  static const String _baseUrl = 'https://api.example.com/v1';

  const AuthRemoteDataSourceImpl({required this.client});

  Map<String, String> get _headers => {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      };

  Map<String, String> _authHeaders(String accessToken) => {
        ..._headers,
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      };

  @override
  Future<AuthTokenModel> login(LoginRequestModel request) async {
    // TODO: Integrate with your backend login endpoint.
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    _checkStatusCode(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthTokenModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register(RegisterRequestModel request) async {
    // TODO: Integrate with your backend register endpoint.
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    _checkStatusCode(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthTokenModel> verifyOtp(OtpRequestModel request) async {
    // TODO: Integrate with your backend OTP verification endpoint.
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/verify-otp'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    _checkStatusCode(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthTokenModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    // TODO: Integrate with your backend logout endpoint.
    // Note: In many stateless JWT systems this is a no-op on the server side.
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/logout'),
      headers: _headers,
    );
    _checkStatusCode(response);
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    // TODO: Integrate with your backend token refresh endpoint.
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: _headers,
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    _checkStatusCode(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthTokenModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthTokenModel> socialLogin(String provider, String token) async {
    // TODO: Integrate with your backend social login endpoint.
    // TODO: Implement Google Sign-In / Facebook Login SDK token retrieval.
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/social'),
      headers: _headers,
      body: jsonEncode({'provider': provider, 'token': token}),
    );
    _checkStatusCode(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthTokenModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getCurrentUser(String accessToken) async {
    // TODO: Integrate with your backend profile endpoint.
    final response = await client.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: _authHeaders(accessToken),
    );
    _checkStatusCode(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  void _checkStatusCode(http.Response response) {
    if (response.statusCode == 401) {
      throw const _UnauthorizedException('Unauthorized');
    }
    if (response.statusCode == 422) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw _ValidationException(
          json['message'] as String? ?? 'Validation error');
    }
    if (response.statusCode >= 500) {
      throw const _ServerException('Server error');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _ServerException('Request failed: ${response.statusCode}');
    }
  }
}

class _ServerException implements Exception {
  final String message;
  const _ServerException(this.message);
}

class _ValidationException implements Exception {
  final String message;
  const _ValidationException(this.message);
}

class _UnauthorizedException implements Exception {
  final String message;
  const _UnauthorizedException(this.message);
}
