import 'dart:convert';

import 'package:mobile_app/core/error/exceptions.dart';

import '../models/referral_code_model.dart';
import '../models/referral_model.dart';
import '../models/referral_reward_model.dart';
import '../models/referral_stats_model.dart';

/// Contract for the remote data source that communicates with the referral API.
abstract class ReferralRemoteDataSource {
  /// Fetches the authenticated user's referral code.
  ///
  /// Throws [ServerException] on any non-2xx response.
  Future<ReferralCodeModel> getReferralCode();

  /// Fetches aggregated referral statistics.
  ///
  /// Throws [ServerException] on any non-2xx response.
  Future<ReferralStatsModel> getReferralStats();

  /// Fetches the list of all referrals initiated by the user.
  ///
  /// Throws [ServerException] on any non-2xx response.
  Future<List<ReferralModel>> getReferrals();

  /// Submits a claim for the reward identified by [rewardId].
  ///
  /// Throws [ServerException] on any non-2xx response.
  Future<ReferralRewardModel> claimReward(String rewardId);

  /// Sends the referral [code] to the server to apply it to the user's account.
  ///
  /// Returns `true` on success. Throws [ServerException] on any non-2xx response.
  Future<bool> applyReferralCode(String code);

  /// Fetches the referral leaderboard.
  ///
  /// Throws [ServerException] on any non-2xx response.
  Future<List<Map<String, dynamic>>> getLeaderboard();
}

/// [ReferralRemoteDataSource] implementation using an HTTP client.
///
/// Inject an HTTP client that already carries the authenticated user's bearer
/// token via its headers.  The [baseUrl] is the root of the API, e.g.
/// `"https://api.alakhservice.com/v1"`.
///
/// All methods decode JSON from the response body and throw [ServerException]
/// for non-2xx status codes.
class ReferralRemoteDataSourceImpl implements ReferralRemoteDataSource {
  /// Creates a [ReferralRemoteDataSourceImpl].
  ///
  /// [httpClient] must be pre-configured with authentication headers.
  /// [baseUrl] must **not** end with a trailing slash.
  ReferralRemoteDataSourceImpl({
    required this.httpClient,
    required this.baseUrl,
  });

  // TODO: Replace `dynamic` with your project's HTTP client type (e.g. Dio or http.Client).
  final dynamic httpClient;

  /// Root API URL without trailing slash, e.g. `"https://api.example.com/v1"`.
  final String baseUrl;

  @override
  Future<ReferralCodeModel> getReferralCode() async {
    // TODO: Replace with actual HTTP client call, e.g.:
    // final response = await httpClient.get(Uri.parse('$baseUrl/referrals/code'));
    final response = await _get('/referrals/code');
    return ReferralCodeModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ReferralStatsModel> getReferralStats() async {
    // TODO: Replace with actual HTTP client call.
    final response = await _get('/referrals/stats');
    return ReferralStatsModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<ReferralModel>> getReferrals() async {
    // TODO: Replace with actual HTTP client call.
    final response = await _get('/referrals');
    final list = response as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(ReferralModel.fromJson)
        .toList();
  }

  @override
  Future<ReferralRewardModel> claimReward(String rewardId) async {
    // TODO: Replace with actual HTTP client call.
    final response = await _post('/referrals/rewards/$rewardId/claim', {});
    return ReferralRewardModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<bool> applyReferralCode(String code) async {
    // TODO: Replace with actual HTTP client call.
    final response =
        await _post('/referrals/apply', {'code': code});
    final map = response as Map<String, dynamic>;
    return map['success'] as bool? ?? false;
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    // TODO: Replace with actual HTTP client call.
    final response = await _get('/referrals/leaderboard');
    final list = response as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Private helpers – replace implementations with your HTTP client of choice.
  // ---------------------------------------------------------------------------

  /// Performs a GET request to [path] and returns the decoded JSON body.
  ///
  /// Throws [ServerException] for non-2xx status codes.
  Future<dynamic> _get(String path) async {
    // TODO: Replace the stub below with your HTTP client implementation.
    // Example using the `http` package:
    //   final uri = Uri.parse('$baseUrl$path');
    //   final response = await (httpClient as http.Client).get(uri);
    //   if (response.statusCode < 200 || response.statusCode >= 300) {
    //     throw ServerException(message: 'HTTP ${response.statusCode}');
    //   }
    //   return jsonDecode(response.body);
    throw UnimplementedError('_get is not implemented: $path');
  }

  /// Performs a POST request to [path] with [body] and returns the decoded
  /// JSON body.
  ///
  /// Throws [ServerException] for non-2xx status codes.
  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    // TODO: Replace the stub below with your HTTP client implementation.
    // Example using the `http` package:
    //   final uri = Uri.parse('$baseUrl$path');
    //   final response = await (httpClient as http.Client).post(
    //     uri,
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(body),
    //   );
    //   if (response.statusCode < 200 || response.statusCode >= 300) {
    //     throw ServerException(message: 'HTTP ${response.statusCode}');
    //   }
    //   return jsonDecode(response.body);
    throw UnimplementedError('_post is not implemented: $path ${jsonEncode(body)}');
  }
}
