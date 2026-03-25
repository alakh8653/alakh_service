import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shop_web/features/dashboard/domain/entities/recent_activity.dart';
import 'package:shop_web/shared/shared.dart';

/// Table of recent booking activities displayed on the Dashboard.
///
/// Accepts the full [activities] list and internally filters to events of
/// type `'booking'`, showing a maximum of 5 rows.
class RecentBookingsTable extends StatelessWidget {
  final List<RecentActivity> activities;

  const RecentBookingsTable({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final bookings = activities
        .where((a) => a.type == 'booking')
        .take(5)
        .toList();

    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Bookings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/bookings'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (bookings.isEmpty)
            const EmptyTableState(message: 'No recent bookings.')
          else
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 40,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 56,
                columns: const [
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Status')),
                ],
                rows: bookings.map((b) {
                  final timeLabel =
                      DateFormat('d MMM, HH:mm').format(b.timestamp.toLocal());
                  return DataRow(cells: [
                    DataCell(Text(
                      timeLabel,
                      style: const TextStyle(fontSize: 13),
                    )),
                    DataCell(
                      Tooltip(
                        message: b.description,
                        child: Text(
                          b.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    DataCell(StatusBadge(
                      status: StatusType.active,
                      label: 'Booked',
                    )),
                  ]);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
