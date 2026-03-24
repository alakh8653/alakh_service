import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/queue_bloc.dart';
import '../bloc/queue_event.dart';
import '../bloc/queue_state.dart';

/// Page that lets a user choose a service and confirm joining the queue.
///
/// Requires a [shopId].  On confirmation it dispatches [JoinQueueEvent].
class JoinQueuePage extends StatefulWidget {
  /// The shop whose queue the user is joining.
  final String shopId;

  /// Creates a [JoinQueuePage].
  const JoinQueuePage({super.key, required this.shopId});

  /// Named route for this page.
  static const routeName = '/queue/join';

  @override
  State<JoinQueuePage> createState() => _JoinQueuePageState();
}

class _JoinQueuePageState extends State<JoinQueuePage> {
  String? _selectedServiceId;

  // Placeholder service list – replace with data from a real API.
  static const List<_ServiceOption> _services = [
    _ServiceOption(id: 'general', name: 'General Service', duration: 15),
    _ServiceOption(id: 'consultation', name: 'Consultation', duration: 30),
    _ServiceOption(id: 'express', name: 'Express Checkout', duration: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<QueueBloc, QueueState>(
      listener: (context, state) {
        if (state is QueueJoined) {
          Navigator.of(context).pop();
        } else if (state is QueueError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Join Queue')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select a service to join the queue.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _services.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final isSelected = _selectedServiceId == service.id;

                  return ListTile(
                    title: Text(service.name),
                    subtitle: Text('~${service.duration} min'),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () =>
                        setState(() => _selectedServiceId = service.id),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<QueueBloc, QueueState>(
                  builder: (context, state) {
                    final isLoading = state is QueueLoading;
                    return FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => context.read<QueueBloc>().add(
                                JoinQueueEvent(
                                  shopId: widget.shopId,
                                  serviceId: _selectedServiceId,
                                ),
                              ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.queue),
                      label: Text(isLoading ? 'Joining…' : 'Confirm & Join'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple immutable data class for a service option shown on [JoinQueuePage].
class _ServiceOption {
  final String id;
  final String name;
  final int duration;

  const _ServiceOption({
    required this.id,
    required this.name,
    required this.duration,
  });
}
