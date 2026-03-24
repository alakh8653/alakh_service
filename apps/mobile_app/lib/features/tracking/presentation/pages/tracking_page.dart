import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tracking_bloc.dart';
import '../bloc/tracking_event.dart';
import '../bloc/tracking_state.dart';
import '../widgets/eta_card.dart';
import '../widgets/live_map_widget.dart';
import '../widgets/tracking_status_bar.dart';

/// Customer-facing live tracking page.
///
/// Displays the staff member's real-time position on a map along with
/// the estimated arrival time and current session status.
class TrackingPage extends StatefulWidget {
  /// The tracking session identifier to observe.
  final String sessionId;

  /// Creates a [TrackingPage].
  const TrackingPage({super.key, required this.sessionId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<TrackingBloc>()
        .add(WatchLocationEvent(sessionId: widget.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Tracking')),
      body: BlocConsumer<TrackingBloc, TrackingState>(
        listener: (context, state) {
          if (state is TrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is TrackingCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Service completed!')),
            );
          }
        },
        builder: (context, state) {
          if (state is TrackingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = switch (state) {
            TrackingActive(:final session) => session,
            LocationUpdatedState(:final session) => session,
            TrackingCompleted(:final session) => session,
            _ => null,
          };

          if (session == null) {
            return const Center(child: Text('Waiting for tracking data…'));
          }

          final location = state is LocationUpdatedState
              ? state.newLocation
              : session.currentLocation;

          return Column(
            children: [
              TrackingStatusBar(
                key: const ValueKey('tracking_status_bar'),
                currentStatus: session.status,
              ),
              Expanded(
                child: LiveMapWidget(
                  key: const ValueKey('live_map'),
                  staffLocation: location,
                  destinationLocation: session.destinationLocation,
                  routePolyline: session.routePolyline,
                ),
              ),
              if (session.eta != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: EtaCard(
                    key: const ValueKey('eta_card'),
                    eta: session.eta!,
                    distanceKm: location != null &&
                            session.destinationLocation != null
                        ? location.distanceTo(session.destinationLocation!) /
                            1000
                        : 0.0,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
