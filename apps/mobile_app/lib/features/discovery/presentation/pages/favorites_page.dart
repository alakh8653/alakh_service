import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/discovery_bloc.dart';
import '../widgets/shop_card.dart';
import 'shop_detail_page.dart';

/// Lists all shops the user has saved as favourites.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  static const routeName = '/discovery/favorites';

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(const LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (ctx, state) {
          if (state is DiscoveryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiscoveryError) {
            return Center(child: Text(state.message));
          }
          if (state is FavoritesLoaded) {
            if (state.shops.isEmpty) {
              return const _EmptyFavorites();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.shops.length,
              itemBuilder: (_, i) {
                final shop = state.shops[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShopCard(
                    shop: shop,
                    isFavorite: true,
                    onTap: () => Navigator.of(context).pushNamed(
                      ShopDetailPage.routeName,
                      arguments: shop.id,
                    ),
                    onFavoriteTap: () {
                      ctx.read<DiscoveryBloc>().add(
                            ToggleFavorite(
                                shopId: shop.id, isFavorite: false),
                          );
                    },
                  ),
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

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No favourites yet.\nTap the heart on any shop to save it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
