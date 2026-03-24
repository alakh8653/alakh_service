import 'package:api_client/api_client.dart';
import 'package:shared_models/shared_models.dart';
import '../services/token_service.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  final ApiClient _apiClient;
  final TokenService _tokenService;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    await _tokenService.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    await _tokenService.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<void>(ApiEndpoints.logout);
    } catch (_) {
      // Clear tokens even if API call fails
    } finally {
      await _tokenService.clearTokens();
    }
  }

  Future<bool> isAuthenticated() => _tokenService.hasValidToken();

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.userProfile,
    );
    return UserModel.fromJson(
      response.data?['data'] as Map<String, dynamic>,
    );
  }
}
