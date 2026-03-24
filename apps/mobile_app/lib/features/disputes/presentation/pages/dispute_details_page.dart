import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dispute_bloc.dart';
import '../bloc/dispute_event.dart';
import '../bloc/dispute_state.dart';
import '../widgets/dispute_status_timeline.dart';
import '../widgets/evidence_gallery.dart';
import '../widgets/resolution_card.dart';
import '../../domain/entities/dispute_status.dart';

class DisputeDetailsPage extends StatefulWidget {
  final String disputeId;
  const DisputeDetailsPage({super.key, required this.disputeId});

  @override
  State<DisputeDetailsPage> createState() => _DisputeDetailsPageState();
}

class _DisputeDetailsPageState extends State<DisputeDetailsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<DisputeBloc>()
        .add(LoadDisputeDetailsEvent(widget.disputeId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispute Details')),
      body: BlocBuilder<DisputeBloc, DisputeState>(
        builder: (context, state) {
          if (state is DisputeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DisputeError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is DisputeDetailLoaded) {
            final dispute = state.dispute;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DisputeStatusTimeline(currentStatus: dispute.status),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${dispute.type.displayName}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Reason: ${dispute.reason}'),
                        const SizedBox(height: 8),
                        Text(dispute.description),
                        const SizedBox(height: 16),
                        const Text('Evidence',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        EvidenceGallery(evidenceList: dispute.evidence),
                        if (dispute.resolution != null) ...[
                          const SizedBox(height: 16),
                          ResolutionCard(
                            resolution: dispute.resolution!,
                            onAccept: dispute.status != DisputeStatus.resolved
                                ? () => context.read<DisputeBloc>().add(
                                    AcceptResolutionEvent(dispute.id))
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
