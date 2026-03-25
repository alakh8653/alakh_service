/// Staff detail page showing member information, schedule, role/permissions,
/// and an activity history section. Supports toggling into edit mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';
import 'package:shop_web/features/staff_management/presentation/bloc/staff_management_bloc.dart';
import 'package:shop_web/features/staff_management/presentation/bloc/staff_management_event.dart';
import 'package:shop_web/features/staff_management/presentation/bloc/staff_management_state.dart';
import 'package:shop_web/features/staff_management/presentation/widgets/role_permission_editor.dart';
import 'package:shop_web/features/staff_management/presentation/widgets/staff_schedule_editor.dart';
import 'package:shop_web/shared/shared.dart';

/// Detailed view for a single staff member.
class StaffDetailPage extends StatefulWidget {
  /// Creates a [StaffDetailPage] for the member with [staffId].
  const StaffDetailPage({super.key, required this.staffId});

  /// ID of the staff member to display.
  final String staffId;

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    context
        .read<StaffManagementBloc>()
        .add(LoadStaffDetail(id: widget.staffId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<StaffManagementBloc, StaffManagementState>(
        listener: (context, state) {
          if (state is StaffManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
          if (state is StaffActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            setState(() => _editMode = false);
          }
        },
        builder: (context, state) {
          if (state is StaffManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StaffDetailLoaded) {
            return _buildDetail(context, state.staffMember);
          }
          if (state is StaffManagementError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, StaffMember member) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: member.name,
            subtitle: member.role,
            actions: [
              if (!_editMode)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _editMode = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                )
              else
                OutlinedButton(
                  onPressed: () => setState(() => _editMode = false),
                  child: const Text('Cancel'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileCard(member: member),
          const SizedBox(height: 24),
          if (!_editMode) ...[
            _ScheduleCard(member: member),
            const SizedBox(height: 24),
            _PermissionsCard(member: member),
            const SizedBox(height: 24),
            _ActivityCard(member: member),
          ] else ...[
            _EditScheduleSection(member: member),
            const SizedBox(height: 24),
            _EditPermissionsSection(member: member),
          ],
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: member.avatarUrl != null
                  ? NetworkImage(member.avatarUrl!)
                  : null,
              child: member.avatarUrl == null
                  ? Text(
                      member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 28),
                    )
                  : null,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Email', value: member.email),
                _InfoRow(label: 'Phone', value: member.phone),
                _InfoRow(label: 'Status', value: member.status.toUpperCase()),
                _InfoRow(
                  label: 'Joined',
                  value: member.joinedAt.toLocal().toString().split(' ')[0],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: value),
            ],
          ),
        ),
      );
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final schedule = member.schedule;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (schedule == null || schedule.isEmpty)
              const Text('No schedule configured.')
            else
              ...schedule.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${e.key}: ${e.value.join(', ')}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permissions',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: member.permissions
                  .map((p) => Chip(
                        label: Text(p, style: const TextStyle(fontSize: 12)),
                        padding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity History',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text('${member.name} joined the team'),
              subtitle: Text(
                  member.joinedAt.toLocal().toString().split(' ')[0]),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditScheduleSection extends StatelessWidget {
  const _EditScheduleSection({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StaffScheduleEditor(
          initialSchedule: member.schedule,
          onSave: (schedule) => context.read<StaffManagementBloc>().add(
                UpdateSchedule(id: member.id, schedule: schedule),
              ),
          onCancel: () {},
        ),
      ),
    );
  }
}

class _EditPermissionsSection extends StatelessWidget {
  const _EditPermissionsSection({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    // Roles list is not available here; a full implementation would read
    // them from a cubit/repository. Placeholder empty list is safe.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RolePermissionEditor(
          availableRoles: const [],
          selectedRoleId: '',
          selectedPermissions: member.permissions,
          onChanged: (roleId, permissions) {
            context.read<StaffManagementBloc>().add(
                  UpdateStaff(
                    staff: member.copyWith(
                      role: roleId,
                      permissions: permissions,
                    ),
                  ),
                );
          },
        ),
      ),
    );
  }
}
