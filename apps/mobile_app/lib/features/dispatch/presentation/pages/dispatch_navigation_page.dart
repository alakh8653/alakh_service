import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dispatch_status.dart';
import '../bloc/dispatch_bloc.dart';
import '../bloc/dispatch_event.dart';
import '../bloc/dispatch_state.dart';
import '../widgets/dispatch_map_widget.dart';
import '../widgets/eta_display.dart';
import '../widgets/dispatch_action_button.dart';

/// Page displayed while the staff member is en route to the pickup location.
///
/// Shows the map, ETA display and an action button to mark arrival.
class DispatchNavigationPage extends StatelessWidget {
  const DispatchNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<DispatchBloc, DispatchState>(
        builder: (context, state) {
          if (state is! EnRouteState) {
            return const Center(child: CircularProgressIndicator());
          }

          final route = state.route;
          final job = state.job;

          return Column(
            children: [
              Expanded(
                child: DispatchMapWidget(
                  route: route,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    EtaDisplay(
                      distanceKm: route.distanceKm,
                      etaSeconds: route.durationSeconds,
                    ),
                    const SizedBox(height: 12),
                    _AddressCard(
                      icon: Icons.my_location_outlined,
                      address: job.pickupLocation.address,
                      label: 'Pickup',
                    ),
                    const SizedBox(height: 8),
                    DispatchActionButton(
                      status: job.status,
                      jobId: job.id,
                      onAction: (nextStatus) {
                        context.read<DispatchBloc>().add(
                              UpdateStatusEvent(jobId: job.id, status: nextStatus),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String address;

  const _AddressCard({
    required this.icon,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              Text(address, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
