import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tracking_bloc.dart';
import '../bloc/tracking_event.dart';
import '../bloc/tracking_state.dart';
import '../widgets/contact_staff_widget.dart';
import '../widgets/eta_card.dart';
import '../widgets/route_info_widget.dart';
import '../widgets/tracking_status_bar.dart';

/// Detailed view of a tracking session.
///
/// Displays the session timeline, ETA, staff contact options, and
/// route information.
class TrackingDetailsPage extends StatefulWidget {
  /// The tracking session identifier.
  final String sessionId;

  /// The staff member's display name.
  final String staffName;

  /// The staff member's phone number for direct contact.
  final String staffPhone;

  /// Creates a [TrackingDetailsPage].
  const TrackingDetailsPage({
    super.key,
    required this.sessionId,
    required this.staffName,
    required this.staffPhone,
  });

  @override
  State<TrackingDetailsPage> createState() => _TrackingDetailsPageState();
}

class _TrackingDetailsPageState extends State<TrackingDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TrackingBloc>().add(
          WatchLocationEvent(sessionId: widget.sessionId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Details')),
      body: BlocBuilder<TrackingBloc, TrackingState>(
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
            return const Center(child: Text('No active session found.'));
          }

          final distanceKm = session.currentLocation != null &&
                  session.destinationLocation != null
              ? session.currentLocation!
                      .distanceTo(session.destinationLocation!) /
                  1000
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrackingStatusBar(
                  key: const ValueKey('details_status_bar'),
                  currentStatus: session.status,
                ),
                const SizedBox(height: 16),
                if (session.eta != null)
                  EtaCard(
                    key: const ValueKey('details_eta_card'),
                    eta: session.eta!,
                    distanceKm: distanceKm,
                  ),
                const SizedBox(height: 16),
                RouteInfoWidget(
                  key: const ValueKey('details_route_info'),
                  distanceKm: distanceKm,
                  eta: session.eta,
                ),
                const SizedBox(height: 24),
                Text(
                  'Contact Staff',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ContactStaffWidget(
                  key: const ValueKey('contact_staff'),
                  staffName: widget.staffName,
                  phoneNumber: widget.staffPhone,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
