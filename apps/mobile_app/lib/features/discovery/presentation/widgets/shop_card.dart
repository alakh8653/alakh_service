import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// A card widget that displays summary information about a [Shop].
class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.shop,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final Shop shop;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroImage(imageUrls: shop.imageUrls, isFavorite: isFavorite, onFavoriteTap: onFavoriteTap),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _OpenBadge(isOpen: shop.isOpen),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shop.address,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StarRating(rating: shop.rating),
                      const SizedBox(width: 4),
                      Text(
                        '${shop.rating.toStringAsFixed(1)} (${shop.reviewCount})',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (shop.distanceKm != null)
                        _DistanceBadge(distanceKm: shop.distanceKm!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── private helpers ──────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.imageUrls,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final List<String> imageUrls;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 140,
          width: double.infinity,
          child: imageUrls.isNotEmpty
              ? Image.network(
                  imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _PlaceholderImage(),
                )
              : _PlaceholderImage(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white.withOpacity(0.85),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onFavoriteTap,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
          child: Icon(Icons.store, size: 48, color: Colors.grey)),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 14, color: Colors.amber);
        } else if (index < rating) {
          return const Icon(Icons.star_half, size: 14, color: Colors.amber);
        }
        return const Icon(Icons.star_border, size: 14, color: Colors.amber);
      }),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.distanceKm});

  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    final label = distanceKm < 1
        ? '${(distanceKm * 1000).round()} m'
        : '${distanceKm.toStringAsFixed(1)} km';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.place, size: 12, color: Colors.blue),
          const SizedBox(width: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.blue)),
        ],
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          fontSize: 11,
          color: isOpen ? Colors.green[700] : Colors.red[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
