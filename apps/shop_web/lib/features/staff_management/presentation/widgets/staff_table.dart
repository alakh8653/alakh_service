/// Widget that displays the staff roster as a sortable data table.
///
/// Shows columns: Avatar+Name, Email, Role, Status badge, Joined date,
/// and an Actions menu with Edit, View Schedule, and Remove options.
library;

import 'package:flutter/material.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';

/// Callback signature for row-level actions.
typedef StaffActionCallback = void Function(StaffMember member);

/// Callback signature for the remove action (needs confirmation).
typedef StaffRemoveCallback = void Function(String id);

/// Data table listing all staff members with per-row action controls.
class StaffTable extends StatelessWidget {
  /// Creates a [StaffTable] with the given [staffList] and action callbacks.
  const StaffTable({
    super.key,
    required this.staffList,
    required this.onEdit,
    required this.onViewSchedule,
    required this.onRemove,
  });

  /// The list of staff members to display.
  final List<StaffMember> staffList;

  /// Called when the user taps Edit on a row.
  final StaffActionCallback onEdit;

  /// Called when the user taps View Schedule on a row.
  final StaffActionCallback onViewSchedule;

  /// Called when the user confirms removal of a staff member.
  final StaffRemoveCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (staffList.isEmpty) {
      return Center(
        child: Text(
          'No staff members found.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          theme.colorScheme.surfaceContainerHighest,
        ),
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Joined')),
          DataColumn(label: Text('Actions')),
        ],
        rows: staffList.map((member) => _buildRow(context, member)).toList(),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, StaffMember member) {
    return DataRow(
      cells: [
        DataCell(_NameCell(member: member)),
        DataCell(Text(member.email)),
        DataCell(Text(member.role)),
        DataCell(_StatusBadge(status: member.status)),
        DataCell(Text(_formatDate(member.joinedAt))),
        DataCell(_ActionsMenu(
          member: member,
          onEdit: onEdit,
          onViewSchedule: onViewSchedule,
          onRemove: onRemove,
        )),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _NameCell extends StatelessWidget {
  const _NameCell({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: member.avatarUrl != null
              ? NetworkImage(member.avatarUrl!)
              : null,
          child: member.avatarUrl == null
              ? Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?')
              : null,
        ),
        const SizedBox(width: 8),
        Text(member.name),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  static const _colours = <String, Color>{
    'active': Color(0xFF4CAF50),
    'inactive': Color(0xFF9E9E9E),
    'invited': Color(0xFF2196F3),
    'suspended': Color(0xFFF44336),
  };

  @override
  Widget build(BuildContext context) {
    final colour = _colours[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colour.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colour),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: colour,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({
    required this.member,
    required this.onEdit,
    required this.onViewSchedule,
    required this.onRemove,
  });

  final StaffMember member;
  final StaffActionCallback onEdit;
  final StaffActionCallback onViewSchedule;
  final StaffRemoveCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit(member);
          case 'schedule':
            onViewSchedule(member);
          case 'remove':
            _confirmRemove(context);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'schedule', child: Text('View Schedule')),
        PopupMenuItem(
          value: 'remove',
          child: Text('Remove', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Staff Member'),
        content: Text('Remove ${member.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              onRemove(member.id);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
