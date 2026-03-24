import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/location.dart';
import '../bloc/tracking_bloc.dart';
import '../bloc/tracking_event.dart';
import '../bloc/tracking_state.dart';
import '../widgets/live_map_widget.dart';
import '../widgets/route_info_widget.dart';

/// Staff-facing tracking page.
///
/// Allows the staff member to start and stop location sharing and
/// view their destination and route information.
class StaffTrackingPage extends StatelessWidget {
  /// The tracking session identifier.
  final String sessionId;

  /// The job identifier associated with this session.
  final String jobId;

  /// Creates a [StaffTrackingPage].
  const StaffTrackingPage({
    super.key,
    required this.sessionId,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Route')),
      body: BlocConsumer<TrackingBloc, TrackingState>(
        listener: (context, state) {
          if (state is TrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isActive = state is TrackingActive ||
              state is LocationUpdatedState;

          final session = switch (state) {
            TrackingActive(:final session) => session,
            LocationUpdatedState(:final session) => session,
            _ => null,
          };

          return Column(
            children: [
              Expanded(
                child: LiveMapWidget(
                  key: const ValueKey('staff_live_map'),
                  staffLocation: session?.currentLocation,
                  destinationLocation: session?.destinationLocation,
                  routePolyline: session?.routePolyline,
                ),
              ),
              if (session != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: RouteInfoWidget(
                    key: const ValueKey('route_info'),
                    distanceKm: session.currentLocation != null &&
                            session.destinationLocation != null
                        ? session.currentLocation!
                                .distanceTo(session.destinationLocation!) /
                            1000
                        : 0.0,
                    eta: session.eta,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isActive) {
                      context
                          .read<TrackingBloc>()
                          .add(StopTrackingEvent(sessionId: sessionId));
                    } else {
                      context
                          .read<TrackingBloc>()
                          .add(StartTrackingEvent(jobId: jobId));
                    }
                  },
                  icon: Icon(isActive ? Icons.stop : Icons.navigation),
                  label: Text(
                      isActive ? 'Stop Sharing Location' : 'Start Navigation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isActive ? Colors.red : Colors.green,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
