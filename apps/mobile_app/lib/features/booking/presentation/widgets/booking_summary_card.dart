import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/booking.dart';

/// A card widget that shows a summary of the booking details.
class BookingSummaryCard extends StatelessWidget {
  final Booking booking;

  const BookingSummaryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Summary', style: textTheme.titleMedium),
            const Divider(height: 24),
            _Row(
              icon: Icons.store_rounded,
              label: 'Shop',
              value: booking.shopName ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _Row(
              icon: Icons.design_services_rounded,
              label: 'Service',
              value: booking.serviceName ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _Row(
              icon: Icons.calendar_today_rounded,
              label: 'Date & Time',
              value: DateFormat('EEE, MMM d • h:mm a').format(booking.dateTime),
            ),
            if (booking.staffName != null) ...[
              const SizedBox(height: 8),
              _Row(
                icon: Icons.person_rounded,
                label: 'Staff',
                value: booking.staffName!,
              ),
            ],
            const SizedBox(height: 8),
            _Row(
              icon: Icons.timer_rounded,
              label: 'Duration',
              value: '${booking.durationMinutes} min',
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: textTheme.titleSmall),
                Text(
                  '\$${booking.totalPrice.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
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

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: textTheme.bodySmall),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
