import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/dispatch_assignment.dart';

/// Card widget that displays an incoming dispatch assignment with a live
/// countdown timer. Calls [onAccept] or [onReject] when the staff responds.
///
/// The card automatically shows a visual urgency indicator as time runs out.
class AssignmentCard extends StatefulWidget {
  final DispatchAssignment assignment;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.assignment.timeout;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _timer?.cancel();
          // Auto-reject on timeout.
          widget.onReject();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _timerColor(BuildContext context) {
    final ratio = _remaining.inSeconds / widget.assignment.timeout.inSeconds;
    if (ratio > 0.5) return Theme.of(context).colorScheme.primary;
    if (ratio > 0.25) return Colors.orange;
    return Theme.of(context).colorScheme.error;
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = widget.assignment;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Job Assignment',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _CountdownBadge(
                  label: _formatDuration(_remaining),
                  color: _timerColor(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.person_outline, label: a.customerName),
            _InfoRow(icon: Icons.design_services_outlined, label: a.serviceType),
            if (a.serviceDescription != null)
              _InfoRow(icon: Icons.notes_outlined, label: a.serviceDescription!),
            _InfoRow(
              icon: Icons.attach_money_outlined,
              label: 'Est. ₹${a.estimatedFare.toStringAsFixed(0)}',
            ),
            const Divider(height: 20),
            _InfoRow(icon: Icons.my_location_outlined, label: a.pickupAddress),
            _InfoRow(icon: Icons.location_on_outlined, label: a.dropoffAddress),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: widget.onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _CountdownBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
