import '../models/models.dart';

/// Contract for remote onboarding data operations.
abstract class OnboardingRemoteDataSource {
  /// Fetches the list of onboarding steps from the remote API.
  Future<List<OnboardingStepModel>> getOnboardingSteps();
}

/// [OnboardingRemoteDataSource] implementation using an HTTP client.
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  // TODO(dev): Inject an http.Client (or Dio) and a base URL.
  //   Example:
  //     final http.Client _client;
  //     final String _baseUrl;
  //     OnboardingRemoteDataSourceImpl(this._client, this._baseUrl);

  @override
  Future<List<OnboardingStepModel>> getOnboardingSteps() async {
    // TODO(dev): Replace with a real HTTP call:
    //   final response = await _client.get(Uri.parse('$_baseUrl/onboarding/steps'));
    //   if (response.statusCode == 200) {
    //     final List<dynamic> body = jsonDecode(response.body) as List;
    //     return body.map((e) => OnboardingStepModel.fromJson(e as Map<String, dynamic>)).toList();
    //   }
    //   throw ServerException('Failed to load onboarding steps');

    // Fallback static data for development / testing.
    return const [
      OnboardingStepModel(
        id: 'step_1',
        title: 'Find Trusted Professionals',
        description:
            'Browse hundreds of verified service providers in your area.',
        imageAsset: 'assets/images/onboarding_1.png',
        order: 0,
      ),
      OnboardingStepModel(
        id: 'step_2',
        title: 'Book in Seconds',
        description:
            'Schedule any home service with just a few taps — no waiting.',
        imageAsset: 'assets/images/onboarding_2.png',
        order: 1,
      ),
      OnboardingStepModel(
        id: 'step_3',
        title: 'Safe & Guaranteed',
        description:
            'Every job is backed by our satisfaction guarantee and insurance.',
        imageAsset: 'assets/images/onboarding_3.png',
        order: 2,
      ),
    ];
  }
}
