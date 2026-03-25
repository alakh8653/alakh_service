/// Widget for editing a staff member's role and associated permissions.
///
/// Displays a role dropdown and a grouped list of permissions with
/// checkboxes. Permissions are organised into categories:
/// Queue, Bookings, Staff, Earnings, and Settings.
library;

import 'package:flutter/material.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_role.dart';

/// Grouped permission categories with their permission keys.
const _permissionGroups = <String, List<String>>{
  'Queue': [
    'queue.view',
    'queue.manage',
    'queue.call_next',
    'queue.reset',
  ],
  'Bookings': [
    'bookings.view',
    'bookings.create',
    'bookings.edit',
    'bookings.cancel',
  ],
  'Staff': [
    'staff.view',
    'staff.invite',
    'staff.edit',
    'staff.remove',
  ],
  'Earnings': [
    'earnings.view',
    'earnings.export',
    'earnings.refund',
  ],
  'Settings': [
    'settings.view',
    'settings.edit',
    'settings.billing',
  ],
};

/// An editor for a member's role selection and fine-grained permissions.
class RolePermissionEditor extends StatefulWidget {
  /// Creates a [RolePermissionEditor].
  ///
  /// [availableRoles] is the list of roles to show in the dropdown.
  /// [selectedRoleId] is the currently assigned role.
  /// [selectedPermissions] is the set of permission keys currently granted.
  /// [onChanged] is called whenever the role or permissions change.
  const RolePermissionEditor({
    super.key,
    required this.availableRoles,
    required this.selectedRoleId,
    required this.selectedPermissions,
    required this.onChanged,
  });

  /// Roles available for selection.
  final List<StaffRole> availableRoles;

  /// Currently selected role ID.
  final String selectedRoleId;

  /// Currently granted permission keys.
  final List<String> selectedPermissions;

  /// Called with (newRoleId, newPermissions) whenever anything changes.
  final void Function(String roleId, List<String> permissions) onChanged;

  @override
  State<RolePermissionEditor> createState() => _RolePermissionEditorState();
}

class _RolePermissionEditorState extends State<RolePermissionEditor> {
  late String _roleId;
  late Set<String> _permissions;

  @override
  void initState() {
    super.initState();
    _roleId = widget.selectedRoleId;
    _permissions = Set<String>.from(widget.selectedPermissions);
  }

  void _onRoleChanged(String? newId) {
    if (newId == null) return;
    final role = widget.availableRoles.firstWhere((r) => r.id == newId,
        orElse: () => widget.availableRoles.first);
    setState(() {
      _roleId = newId;
      _permissions = Set<String>.from(role.permissions);
    });
    widget.onChanged(_roleId, _permissions.toList());
  }

  void _togglePermission(String key) {
    setState(() {
      if (_permissions.contains(key)) {
        _permissions.remove(key);
      } else {
        _permissions.add(key);
      }
    });
    widget.onChanged(_roleId, _permissions.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _roleId.isEmpty ? null : _roleId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: widget.availableRoles
              .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
              .toList(),
          onChanged: _onRoleChanged,
        ),
        const SizedBox(height: 16),
        Text('Permissions', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._permissionGroups.entries.map(
          (entry) => _PermissionGroup(
            category: entry.key,
            permissions: entry.value,
            selected: _permissions,
            onToggle: _togglePermission,
          ),
        ),
      ],
    );
  }
}

class _PermissionGroup extends StatelessWidget {
  const _PermissionGroup({
    required this.category,
    required this.permissions,
    required this.selected,
    required this.onToggle,
  });

  final String category;
  final List<String> permissions;
  final Set<String> selected;
  final void Function(String key) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(category, style: theme.textTheme.titleSmall),
        initiallyExpanded: true,
        children: permissions
            .map(
              (key) => CheckboxListTile(
                dense: true,
                title: Text(
                  key.split('.').last.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: Text(key, style: const TextStyle(fontSize: 11)),
                value: selected.contains(key),
                onChanged: (_) => onToggle(key),
              ),
            )
            .toList(),
      ),
    );
  }
}
