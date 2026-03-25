import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../bloc/discovery_bloc.dart';
import '../widgets/widgets.dart';
import 'search_results_page.dart';
import 'shop_detail_page.dart';
import 'category_page.dart';

/// The main discovery home page.
///
/// Shows a search bar, category grid, trending carousel, and a list of
/// nearby shops.
class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  static const routeName = '/discovery';

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  // Placeholder coordinates – replace with actual device location.
  static const double _defaultLat = 28.6139;
  static const double _defaultLng = 77.2090;

  final Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(const LoadDiscoveryHome(
          latitude: _defaultLat,
          longitude: _defaultLng,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Navigator.of(context)
                .pushNamed(FavoritesPage.routeName),
          ),
        ],
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (ctx, state) {
          if (state is DiscoveryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiscoveryError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => ctx.read<DiscoveryBloc>().add(
                    const LoadDiscoveryHome(
                      latitude: _defaultLat,
                      longitude: _defaultLng,
                    ),
                  ),
            );
          }
          if (state is DiscoveryHomeLoaded) {
            return _HomeContent(
              state: state,
              favoriteIds: _favoriteIds,
              onFavoriteToggle: (id, isFav) {
                setState(() {
                  if (isFav) {
                    _favoriteIds.add(id);
                  } else {
                    _favoriteIds.remove(id);
                  }
                });
                ctx.read<DiscoveryBloc>().add(
                      ToggleFavorite(shopId: id, isFavorite: isFav),
                    );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.state,
    required this.favoriteIds,
    required this.onFavoriteToggle,
  });

  final DiscoveryHomeLoaded state;
  final Set<String> favoriteIds;
  final void Function(String shopId, bool isFavorite) onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBarWidget(
              recentSearches: state.recentSearches,
              onSubmitted: (q) => Navigator.of(context).pushNamed(
                SearchResultsPage.routeName,
                arguments: q,
              ),
            ),
          ),
        ),
        if (state.categories.isNotEmpty) ...[
          const _SectionHeader('Categories'),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: CategoryGrid(
                categories: state.categories,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onCategoryTap: (c) => Navigator.of(context).pushNamed(
                  CategoryPage.routeName,
                  arguments: c,
                ),
              ),
            ),
          ),
        ],
        if (state.trendingServices.isNotEmpty) ...[
          const _SectionHeader('Trending Services'),
          SliverToBoxAdapter(
            child: TrendingCarousel(
              services: state.trendingServices,
              onServiceTap: (s) => Navigator.of(context).pushNamed(
                ShopDetailPage.routeName,
                arguments: s.shopId,
              ),
            ),
          ),
        ],
        if (state.nearbyShops.isNotEmpty) ...[
          const _SectionHeader('Nearby Shops'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final shop = state.nearbyShops[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ShopCard(
                      shop: shop,
                      isFavorite: favoriteIds.contains(shop.id),
                      onTap: () => Navigator.of(ctx).pushNamed(
                        ShopDetailPage.routeName,
                        arguments: shop.id,
                      ),
                      onFavoriteTap: () => onFavoriteToggle(
                        shop.id,
                        !favoriteIds.contains(shop.id),
                      ),
                    ),
                  );
                },
                childCount: state.nearbyShops.length,
              ),
            ),
          ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
