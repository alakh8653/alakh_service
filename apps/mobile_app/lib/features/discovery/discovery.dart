/// Discovery feature module.
///
/// Provides shop and service discovery including search, categories,
/// nearby listings, trending services, and favourites management.
///
/// Entry points:
/// * [DiscoveryPage] — main home page
/// * [DiscoveryBloc] — BLoC for all discovery state
/// * [DiscoveryRepositoryImpl] — concrete repository (wire via DI)
library discovery;

export 'core/failures.dart';
export 'data/data.dart';
export 'domain/domain.dart';
export 'presentation/presentation.dart';
