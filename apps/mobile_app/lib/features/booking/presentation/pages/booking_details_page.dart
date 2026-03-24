import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../bloc/bloc.dart';
import '../widgets/booking_status_badge.dart';
import 'reschedule_page.dart';

/// Shows the full details of a booking and exposes cancel/reschedule actions
/// depending on the current [BookingStatus].
class BookingDetailsPage extends StatefulWidget {
  /// Identifier of the booking to display.
  final String bookingId;

  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(LoadBookingDetails(widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking cancelled.')),
            );
            context
                .read<BookingBloc>()
                .add(LoadBookingDetails(widget.bookingId));
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingDetailsLoaded) {
            return _BookingDetailsBody(booking: state.booking);
          }
          if (state is BookingError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _BookingDetailsBody extends StatelessWidget {
  final Booking booking;

  const _BookingDetailsBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final canModify = booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status', style: textTheme.titleSmall),
              BookingStatusBadge(status: booking.status),
            ],
          ),
          const Divider(height: 28),

          // Details
          _DetailRow(
            icon: Icons.store_rounded,
            label: 'Shop',
            value: booking.shopName ?? '—',
          ),
          _DetailRow(
            icon: Icons.design_services_rounded,
            label: 'Service',
            value: booking.serviceName ?? '—',
          ),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date & Time',
            value:
                DateFormat('EEEE, MMMM d, y • h:mm a').format(booking.dateTime),
          ),
          _DetailRow(
            icon: Icons.timer_rounded,
            label: 'Duration',
            value: '${booking.durationMinutes} minutes',
          ),
          if (booking.staffName != null)
            _DetailRow(
              icon: Icons.person_rounded,
              label: 'Staff',
              value: booking.staffName!,
            ),
          if (booking.notes != null && booking.notes!.isNotEmpty)
            _DetailRow(
              icon: Icons.notes_rounded,
              label: 'Notes',
              value: booking.notes!,
            ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price', style: textTheme.titleMedium),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(2)}',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (canModify) ...[
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _reschedule(context),
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Reschedule'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Booking'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _reschedule(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BookingBloc>(),
          child: ReschedulePage(bookingId: booking.id),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this booking?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No, Keep it'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingBloc>().add(CancelBooking(
                    bookingId: booking.id,
                    reason: reasonController.text.trim(),
                  ));
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant)),
                Text(value, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
