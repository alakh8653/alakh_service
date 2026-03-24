import 'package:flutter/material.dart';
import '../../domain/entities/dispatch_location.dart';
import '../../domain/entities/dispatch_route.dart';

/// Placeholder widget that will host the maps SDK integration.
///
// TODO: Replace [Container] placeholder with actual maps SDK widget
// (e.g., google_maps_flutter or flutter_map) once the dependency is added.
class DispatchMapWidget extends StatelessWidget {
  /// Optional route to display on the map.
  final DispatchRoute? route;

  /// Optional current staff location marker.
  final DispatchLocation? currentLocation;

  const DispatchMapWidget({
    super.key,
    this.route,
    this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // TODO: Replace with maps SDK widget.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 64, color: colorScheme.outline),
                const SizedBox(height: 8),
                Text(
                  'Map View',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: colorScheme.outline),
                ),
                if (route != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${route!.distanceKm.toStringAsFixed(1)} km route loaded',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colorScheme.outline),
                    ),
                  ),
              ],
            ),
          ),
          if (route != null)
            Positioned(
              top: 12,
              right: 12,
              child: _MapInfoBadge(route: route!),
            ),
        ],
      ),
    );
  }
}

class _MapInfoBadge extends StatelessWidget {
  final DispatchRoute route;

  const _MapInfoBadge({required this.route});

  @override
  Widget build(BuildContext context) {
    final mins = (route.durationSeconds / 60).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$mins min',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
