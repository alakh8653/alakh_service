import 'package:mobile_app/core/error/exceptions.dart';

import '../models/referral_code_model.dart';
import '../models/referral_model.dart';
import '../models/referral_reward_model.dart';
import '../models/referral_stats_model.dart';

/// Minimal interface for the HTTP client used by [ReferralRemoteDataSourceImpl].
///
/// Implement this interface with your preferred HTTP package (e.g. `http` or
/// `Dio`) so that the data-source remains testable and decoupled from any
/// specific transport library.
abstract class HttpClient {
  /// Sends a GET request to [path] relative to the configured base URL.
  ///
  /// Returns the decoded JSON body. Throws [ServerException] on non-2xx status.
  Future<dynamic> get(String path);

  /// Sends a POST request to [path] with the JSON-encoded [body].
  ///
  /// Returns the decoded JSON body. Throws [ServerException] on non-2xx status.
  Future<dynamic> post(String path, Map<String, dynamic> body);
}

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

/// [ReferralRemoteDataSource] implementation using an [HttpClient].
///
/// Inject an [HttpClient] implementation that already carries the authenticated
/// user's bearer token via its headers.  The [baseUrl] is the root of the API,
/// e.g. `"https://api.alakhservice.com/v1"`.
///
/// All methods decode JSON from the response body and throw [ServerException]
/// for non-2xx status codes.
class ReferralRemoteDataSourceImpl implements ReferralRemoteDataSource {
  /// Creates a [ReferralRemoteDataSourceImpl].
  ///
  /// [httpClient] must be pre-configured with authentication headers.
  /// [baseUrl] must **not** end with a trailing slash.
  // TODO: Provide a concrete [HttpClient] implementation that wraps your
  // chosen HTTP package (e.g. Dio or the `http` package).
  const ReferralRemoteDataSourceImpl({
    required HttpClient httpClient,
    required String baseUrl,
  })  : _httpClient = httpClient,
        _baseUrl = baseUrl;

  final HttpClient _httpClient;

  /// Root API URL without trailing slash, e.g. `"https://api.example.com/v1"`.
  final String _baseUrl;

  @override
  Future<ReferralCodeModel> getReferralCode() async {
    final response = await _httpClient.get('$_baseUrl/referrals/code');
    return ReferralCodeModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ReferralStatsModel> getReferralStats() async {
    final response = await _httpClient.get('$_baseUrl/referrals/stats');
    return ReferralStatsModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<ReferralModel>> getReferrals() async {
    final response = await _httpClient.get('$_baseUrl/referrals');
    final list = response as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(ReferralModel.fromJson)
        .toList();
  }

  @override
  Future<ReferralRewardModel> claimReward(String rewardId) async {
    final response =
        await _httpClient.post('$_baseUrl/referrals/rewards/$rewardId/claim', {});
    return ReferralRewardModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<bool> applyReferralCode(String code) async {
    final response =
        await _httpClient.post('$_baseUrl/referrals/apply', {'code': code});
    final map = response as Map<String, dynamic>;
    return map['success'] as bool? ?? false;
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await _httpClient.get('$_baseUrl/referrals/leaderboard');
    final list = response as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
