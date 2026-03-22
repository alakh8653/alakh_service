import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../bloc/discovery_bloc.dart';
import '../widgets/widgets.dart';
import 'shop_detail_page.dart';

/// Displays search results with filtering and list/map view toggle.
class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key, required this.query});

  final String query;

  static const routeName = '/discovery/search';

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool _showMap = false;
  SearchFilters _filters = const SearchFilters();
  final Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _search();
  }

  void _search() {
    context.read<DiscoveryBloc>().add(
          SearchRequested(query: widget.query, filters: _filters),
        );
  }

  void _openFilterSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterBottomSheet(
        initialFilters: _filters,
        onApply: (f) {
          setState(() => _filters = f);
          ctx.read<DiscoveryBloc>().add(FilterChanged(f));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('"${widget.query}"'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map_outlined),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _openFilterSheet(context),
          ),
        ],
      ),
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
              return const _EmptyResults();
            }
            if (_showMap) {
              return MapViewWidget(
                shops: shops,
                latitude: 28.6139,
                longitude: 77.2090,
                onShopTap: (s) => Navigator.of(context).pushNamed(
                  ShopDetailPage.routeName,
                  arguments: s.id,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: shops.length,
              itemBuilder: (_, i) {
                final shop = shops[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShopCard(
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

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No results found.\nTry a different search or adjust filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
