import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/discovery_bloc.dart';
import '../widgets/service_tile.dart';

/// Shows full details of a shop, including its services, ratings, and a
/// "Book Now" button.
class ShopDetailPage extends StatefulWidget {
  const ShopDetailPage({super.key, required this.shopId});

  final String shopId;

  static const routeName = '/discovery/shop';

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<DiscoveryBloc>()
        .add(ShopDetailRequested(widget.shopId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryBloc, DiscoveryState>(
      builder: (ctx, state) {
        if (state is DiscoveryLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (state is DiscoveryError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is ShopDetailLoaded) {
          final shop = state.shop;
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(shop.name,
                        style: const TextStyle(
                            shadows: [Shadow(blurRadius: 4)])),
                    background: shop.imageUrls.isNotEmpty
                        ? Image.network(shop.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300]))
                        : Container(color: Colors.grey[300]),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.white),
                      onPressed: () => ctx.read<DiscoveryBloc>().add(
                            ToggleFavorite(
                                shopId: shop.id, isFavorite: true),
                          ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                            icon: Icons.place,
                            text: '${shop.address}, ${shop.city}'),
                        if (shop.phone != null)
                          _InfoRow(icon: Icons.phone, text: shop.phone!),
                        _InfoRow(
                          icon: Icons.star,
                          text:
                              '${shop.rating.toStringAsFixed(1)} · ${shop.reviewCount} reviews',
                          iconColor: Colors.amber,
                        ),
                        _InfoRow(
                          icon: shop.isOpen ? Icons.check_circle : Icons.cancel,
                          text: shop.isOpen ? 'Open Now' : 'Closed',
                          iconColor:
                              shop.isOpen ? Colors.green : Colors.red,
                        ),
                        if (shop.description != null) ...[
                          const SizedBox(height: 12),
                          Text(shop.description!,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state.services.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text('Services',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ServiceTile(
                        service: state.services[i],
                        onBook: () {
                          // TODO: navigate to booking flow
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Booking ${state.services[i].name}…')),
                          );
                        },
                      ),
                      childCount: state.services.length,
                    ),
                  ),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: navigate to booking flow
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Opening booking…')),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Book Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ),
          );
        }
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
