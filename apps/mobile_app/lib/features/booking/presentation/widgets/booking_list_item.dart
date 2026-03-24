import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/booking.dart';
import 'booking_status_badge.dart';

/// A list tile that represents a single booking in a list view.
///
/// Tapping the tile fires [onTap].
class BookingListItem extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const BookingListItem({super.key, required this.booking, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _ServiceIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.shopName ?? 'Unknown Shop',
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.serviceName ?? 'Unknown Service',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEE, MMM d • h:mm a').format(booking.dateTime),
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BookingStatusBadge(status: booking.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.cut_rounded,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}
