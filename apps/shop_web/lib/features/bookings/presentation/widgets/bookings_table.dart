/// Widget that renders the bookings data table.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_bloc.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_event.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_state.dart';
import 'package:shop_web/features/bookings/presentation/pages/booking_detail_modal.dart';
import 'package:shop_web/shared/shared.dart';

/// Data table showing bookings with sortable columns and per-row actions.
class BookingsTable extends StatelessWidget {
  const BookingsTable({
    super.key,
    required this.bookings,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.sortBy,
    required this.sortAsc,
    required this.onPageChanged,
    this.actionBookingId,
  });

  final List<ShopBooking> bookings;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final String sortBy;
  final bool sortAsc;
  final ValueChanged<int> onPageChanged;

  /// ID of the booking currently undergoing an action (shows spinner).
  final String? actionBookingId;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShopBookingsBloc>();

    return ShopDataTable(
      columns: const [
        ShopDataColumn(label: 'ID', field: 'id'),
        ShopDataColumn(label: 'Customer', field: 'customer_name'),
        ShopDataColumn(label: 'Service', field: 'service_name'),
        ShopDataColumn(label: 'Date', field: 'booking_date'),
        ShopDataColumn(label: 'Time', field: 'time_slot'),
        ShopDataColumn(label: 'Staff', field: 'staff_name'),
        ShopDataColumn(label: 'Status', field: 'status'),
        ShopDataColumn(label: 'Actions', field: '', sortable: false),
      ],
      sortBy: sortBy,
      sortAsc: sortAsc,
      onSort: (field, asc) =>
          bloc.add(SortBookings(column: field, ascending: asc)),
      totalCount: totalCount,
      currentPage: currentPage,
      pageSize: pageSize,
      onPageChanged: onPageChanged,
      rows: bookings.map((booking) => _buildRow(context, booking)).toList(),
    );
  }

  DataRow _buildRow(BuildContext context, ShopBooking booking) {
    final bloc = context.read<ShopBookingsBloc>();
    final isActing = actionBookingId == booking.id;

    return DataRow(
      cells: [
        DataCell(
          Text(
            '#${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(booking.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(booking.customerPhone,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(booking.serviceName),
              Text(
                '\$${booking.servicePrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        DataCell(Text(_formatDate(booking.bookingDate))),
        DataCell(Text(booking.timeSlot)),
        DataCell(Text(booking.staffName ?? '—')),
        DataCell(_buildStatusBadge(booking.status)),
        DataCell(
          isActing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ActionMenu(
                  items: _buildActions(context, booking, bloc),
                ),
        ),
      ],
    );
  }

  List<ActionMenuItem> _buildActions(
    BuildContext context,
    ShopBooking booking,
    ShopBookingsBloc bloc,
  ) {
    return [
      ActionMenuItem(
        label: 'View Details',
        icon: Icons.visibility_outlined,
        onTap: () => BookingDetailModal.show(context, booking),
      ),
      if (booking.isPending)
        ActionMenuItem(
          label: 'Confirm',
          icon: Icons.check_circle_outline,
          onTap: () => bloc.add(
            UpdateBookingStatus(id: booking.id, status: 'confirmed'),
          ),
        ),
      if (!booking.isCancelled && !booking.isCompleted && !booking.isNoShow)
        ActionMenuItem(
          label: 'Cancel',
          icon: Icons.cancel_outlined,
          isDestructive: true,
          onTap: () => _showCancelDialog(context, booking, bloc),
        ),
      if (booking.isConfirmed)
        ActionMenuItem(
          label: 'Mark Complete',
          icon: Icons.task_alt,
          onTap: () => bloc.add(
            UpdateBookingStatus(id: booking.id, status: 'completed'),
          ),
        ),
      if (booking.isConfirmed)
        ActionMenuItem(
          label: 'Mark No-Show',
          icon: Icons.person_off_outlined,
          onTap: () => bloc.add(
            UpdateBookingStatus(id: booking.id, status: 'noShow'),
          ),
        ),
    ];
  }

  void _showCancelDialog(
    BuildContext context,
    ShopBooking booking,
    ShopBookingsBloc bloc,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Cancel Booking',
        message:
            'Are you sure you want to cancel the booking for ${booking.customerName}?',
        confirmLabel: 'Cancel Booking',
        isDangerous: true,
        onConfirm: () =>
            bloc.add(CancelBooking(id: booking.id, reason: 'Cancelled by staff')),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusMap = <String, StatusType>{
      'confirmed': StatusType.success,
      'pending': StatusType.warning,
      'completed': StatusType.info,
      'cancelled': StatusType.error,
      'noShow': StatusType.neutral,
    };
    return StatusBadge(
      label: _statusLabel(status),
      type: statusMap[status] ?? StatusType.neutral,
    );
  }

  String _statusLabel(String status) {
    const labels = <String, String>{
      'confirmed': 'Confirmed',
      'pending': 'Pending',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'noShow': 'No-Show',
    };
    return labels[status] ?? status;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
