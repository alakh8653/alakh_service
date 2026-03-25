import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../bloc/discovery_bloc.dart';
import '../widgets/shop_card.dart';
import 'shop_detail_page.dart';

/// Displays all shops belonging to a specific [Category].
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.category});

  final Category category;

  static const routeName = '/discovery/category';

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(
          SearchRequested(
            query: widget.category.name,
            filters: SearchFilters(categoryId: widget.category.id),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (ctx, state) {
          if (state is DiscoveryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiscoveryError) {
            return Center(child: Text(state.message));
          }
          if (state is SearchResultsLoaded) {
            final shops = state.result.shops;
            if (shops.isEmpty) {
              return const Center(
                child: Text('No shops found in this category.'),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: shops.length,
              itemBuilder: (_, i) {
                final shop = shops[i];
                return ShopCard(
                  shop: shop,
                  isFavorite: _favoriteIds.contains(shop.id),
                  onTap: () => Navigator.of(context).pushNamed(
                    ShopDetailPage.routeName,
                    arguments: shop.id,
                  ),
                  onFavoriteTap: () {
                    setState(() {
                      if (_favoriteIds.contains(shop.id)) {
                        _favoriteIds.remove(shop.id);
                      } else {
                        _favoriteIds.add(shop.id);
                      }
                    });
                    ctx.read<DiscoveryBloc>().add(ToggleFavorite(
                          shopId: shop.id,
                          isFavorite: !_favoriteIds.contains(shop.id),
                        ));
                  },
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
