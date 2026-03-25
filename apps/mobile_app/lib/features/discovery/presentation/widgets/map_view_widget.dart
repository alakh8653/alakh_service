import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// Placeholder map view widget.
///
/// TODO: Replace with `google_maps_flutter` integration once the API key is
/// configured and the package is added to pubspec.yaml.
class MapViewWidget extends StatelessWidget {
  const MapViewWidget({
    super.key,
    required this.shops,
    required this.latitude,
    required this.longitude,
    this.onShopTap,
  });

  final List<Shop> shops;
  final double latitude;
  final double longitude;
  final void Function(Shop shop)? onShopTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 64, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'Map View\n(${shops.length} shops nearby)',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
              ),
            ],
          ),
          if (shops.isNotEmpty)
            Positioned(
              bottom: 12,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.list),
                label: const Text('Show List'),
              ),
            ),
        ],
      ),
    );
  }
}
