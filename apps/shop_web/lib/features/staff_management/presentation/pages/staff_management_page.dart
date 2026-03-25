/// Main page for the Staff Management feature.
///
/// Displays the staff roster with search, role filter, status filter,
/// and an Add Staff button. Hosts [StaffTable] and delegates actions
/// to [StaffManagementBloc].
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_web/core/routing/shop_route_names.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';
import 'package:shop_web/features/staff_management/presentation/bloc/staff_management_bloc.dart';
import 'package:shop_web/features/staff_management/presentation/bloc/staff_management_event.dart';
import 'package:shop_web/features/staff_management/presentation/bloc/staff_management_state.dart';
import 'package:shop_web/features/staff_management/presentation/widgets/staff_table.dart';
import 'package:shop_web/shared/shared.dart';

/// The staff management list page.
class StaffManagementPage extends StatefulWidget {
  /// Creates the [StaffManagementPage].
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StaffManagementBloc>().add(const LoadStaff());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<StaffManagementBloc, StaffManagementState>(
        listener: (context, state) {
          if (state is StaffManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is StaffActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Staff Management',
                  subtitle: 'Manage your team members, roles and schedules.',
                  actions: [
                    FilledButton.icon(
                      onPressed: () =>
                          context.pushNamed(ShopRouteNames.inviteStaff),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Invite Staff'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFilters(context, state),
                const SizedBox(height: 16),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context, StaffManagementState state) {
    final bloc = context.read<StaffManagementBloc>();
    final roles = state is StaffManagementLoaded
        ? state.roles.map((r) => r.name).toList()
        : <String>[];

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by name or email…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (q) => bloc.add(SearchStaff(query: q)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _FilterDropdown(
            label: 'Role',
            options: roles,
            value: state is StaffManagementLoaded ? state.roleFilter : '',
            onChanged: (v) => bloc.add(FilterByRole(role: v)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _FilterDropdown(
            label: 'Status',
            options: const ['active', 'inactive', 'invited', 'suspended'],
            value: state is StaffManagementLoaded ? state.statusFilter : '',
            onChanged: (v) => bloc.add(FilterByStatus(status: v)),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, StaffManagementState state) {
    if (state is StaffManagementLoading ||
        state is StaffActionInProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StaffManagementLoaded) {
      return StaffTable(
        staffList: state.filteredStaff,
        onEdit: (m) =>
            context.pushNamed(ShopRouteNames.staffDetail, pathParameters: {'id': m.id}),
        onViewSchedule: (m) =>
            context.pushNamed(ShopRouteNames.staffDetail, pathParameters: {'id': m.id}),
        onRemove: (id) =>
            context.read<StaffManagementBloc>().add(RemoveStaff(id: id)),
      );
    }

    if (state is StaffManagementError) {
      return _ErrorView(
        message: state.message,
        onRetry: () =>
            context.read<StaffManagementBloc>().add(const LoadStaff()),
      );
    }

    return const SizedBox.shrink();
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem(value: '', child: Text('All ${label}s')),
        ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
      ],
      onChanged: (v) => onChanged(v ?? ''),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
