import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dispatch_assignment.dart';
import '../bloc/dispatch_bloc.dart';
import '../bloc/dispatch_event.dart';
import '../bloc/dispatch_state.dart';
import '../widgets/assignment_card.dart';

/// Full-screen page presented when a new dispatch assignment arrives.
///
/// The [DispatchAssignment] should be passed via [ModalRoute.settings.arguments].
class DispatchAssignmentPage extends StatelessWidget {
  final DispatchAssignment assignment;

  const DispatchAssignmentPage({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<DispatchBloc, DispatchState>(
        listener: (context, state) {
          if (state is JobAcceptedState || state is DispatchIdle) {
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  'Incoming Assignment',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please respond before the timer expires.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: AssignmentCard(
                      assignment: assignment,
                      onAccept: () {
                        context.read<DispatchBloc>().add(
                              AcceptJobEvent(jobId: assignment.jobId),
                            );
                      },
                      onReject: () {
                        context.read<DispatchBloc>().add(
                              RejectJobEvent(jobId: assignment.jobId),
                            );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
