/// Modal dialog that displays full details for a single booking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_bloc.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_event.dart';
import 'package:shop_web/shared/shared.dart';

/// A full-featured booking detail dialog.
///
/// Shows customer details, service info, booking metadata, a visual status
/// timeline, and contextual action buttons (confirm, complete, cancel).
///
/// Open via [BookingDetailModal.show].
class BookingDetailModal extends StatelessWidget {
  const BookingDetailModal({super.key, required this.booking});

  final ShopBooking booking;

  /// Opens this modal as a centred dialog.
  static Future<void> show(BuildContext context, ShopBooking booking) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ShopBookingsBloc>(),
        child: BookingDetailModal(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, theme),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSection(
                      theme,
                      title: 'Customer',
                      icon: Icons.person_outline,
                      children: [
                        _InfoRow(label: 'Name', value: booking.customerName),
                        _InfoRow(label: 'Phone', value: booking.customerPhone),
                        _InfoRow(label: 'Email', value: booking.customerEmail),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      theme,
                      title: 'Service',
                      icon: Icons.spa_outlined,
                      children: [
                        _InfoRow(label: 'Service', value: booking.serviceName),
                        _InfoRow(
                          label: 'Price',
                          value:
                              '\$${booking.servicePrice.toStringAsFixed(2)}',
                        ),
                        _InfoRow(
                          label: 'Date',
                          value: _formatDate(booking.bookingDate),
                        ),
                        _InfoRow(label: 'Time Slot', value: booking.timeSlot),
                        if (booking.staffName != null)
                          _InfoRow(
                            label: 'Assigned Staff',
                            value: booking.staffName!,
                          ),
                      ],
                    ),
                    if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSection(
                        theme,
                        title: 'Notes',
                        icon: Icons.notes,
                        children: [
                          Text(
                            booking.notes!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildStatusTimeline(theme),
                    const SizedBox(height: 20),
                    _buildActions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Icon(
            Icons.event_note,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking #${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Created ${_formatDate(booking.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: _statusLabel(booking.status),
            type: _statusType(booking.status),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            color: theme.colorScheme.onPrimaryContainer,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(ThemeData theme) {
    const statuses = [
      ('pending', 'Pending', Icons.hourglass_empty),
      ('confirmed', 'Confirmed', Icons.check_circle_outline),
      ('completed', 'Completed', Icons.task_alt),
    ];

    final activeIndex = statuses.indexWhere((s) => s.$1 == booking.status);
    final isCancelled =
        booking.isCancelled || booking.isNoShow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Timeline',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        if (isCancelled)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cancel_outlined, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  booking.isCancelled ? 'Booking Cancelled' : 'Customer No-Show',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: List.generate(statuses.length, (i) {
              final isActive = i <= activeIndex;
              final isCurrent = i == activeIndex;
              return Expanded(
                child: Row(
                  children: [
                    _TimelineStep(
                      label: statuses[i].$2,
                      icon: statuses[i].$3,
                      isActive: isActive,
                      isCurrent: isCurrent,
                    ),
                    if (i < statuses.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isActive && i < activeIndex
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final bloc = context.read<ShopBookingsBloc>();
    final actions = <Widget>[];

    if (booking.isPending) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            bloc.add(
              UpdateBookingStatus(id: booking.id, status: 'confirmed'),
            );
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Confirm'),
        ),
      );
    }

    if (booking.isConfirmed) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            bloc.add(
              UpdateBookingStatus(id: booking.id, status: 'completed'),
            );
          },
          icon: const Icon(Icons.task_alt),
          label: const Text('Mark Complete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
      actions.add(
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            bloc.add(
              UpdateBookingStatus(id: booking.id, status: 'noShow'),
            );
          },
          icon: const Icon(Icons.person_off_outlined),
          label: const Text('Mark No-Show'),
        ),
      );
    }

    if (!booking.isCancelled && !booking.isCompleted && !booking.isNoShow) {
      actions.add(
        OutlinedButton.icon(
          onPressed: () => _showCancelDialog(context, bloc),
          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
          label: const Text(
            'Cancel Booking',
            style: TextStyle(color: Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions,
    );
  }

  void _showCancelDialog(BuildContext context, ShopBookingsBloc bloc) {
    showDialog<void>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Cancel Booking',
        message:
            'Are you sure you want to cancel the booking for ${booking.customerName}?',
        confirmLabel: 'Yes, Cancel',
        isDangerous: true,
        onConfirm: () {
          Navigator.of(context).pop();
          bloc.add(
            CancelBooking(
              id: booking.id,
              reason: 'Cancelled via booking detail',
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    const labels = {
      'confirmed': 'Confirmed',
      'pending': 'Pending',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'noShow': 'No-Show',
    };
    return labels[status] ?? status;
  }

  StatusType _statusType(String status) {
    switch (status) {
      case 'confirmed':
        return StatusType.success;
      case 'pending':
        return StatusType.warning;
      case 'completed':
        return StatusType.info;
      case 'cancelled':
        return StatusType.error;
      default:
        return StatusType.neutral;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// A single step indicator used in the status timeline.
class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isCurrent,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isActive ? theme.colorScheme.primary : theme.disabledColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? theme.colorScheme.primaryContainer : null,
            border: Border.all(color: color, width: isCurrent ? 2 : 1),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A label-value row used inside detail sections.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
