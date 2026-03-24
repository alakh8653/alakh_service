import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:admin_web/shared/shared.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';
import 'package:admin_web/features/city_management/presentation/bloc/city_bloc.dart';
import 'package:admin_web/features/city_management/presentation/bloc/city_event.dart';
import 'package:admin_web/features/city_management/presentation/bloc/city_state.dart';
import 'package:admin_web/features/city_management/presentation/widgets/city_form.dart';

class CityListPage extends StatelessWidget {
  final String? detailId;
  final bool showCreateForm;

  const CityListPage({
    super.key,
    this.detailId,
    this.showCreateForm = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CityBloc>(
      create: (_) => GetIt.instance<CityBloc>()..add(const LoadCities()),
      child: _CityListView(detailId: detailId, showCreateForm: showCreateForm),
    );
  }
}

class _CityListView extends StatefulWidget {
  final String? detailId;
  final bool showCreateForm;

  const _CityListView({this.detailId, this.showCreateForm = false});

  @override
  State<_CityListView> createState() => _CityListViewState();
}

class _CityListViewState extends State<_CityListView> {
  bool? _activeFilter;

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CityBloc>(),
        child: Dialog(
          child: SizedBox(
            width: 600,
            child: CityForm(
              onSubmit: (params) {
                context.read<CityBloc>().add(CreateCityEvent(params));
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'City Management',
      body: BlocConsumer<CityBloc, CityState>(
        listener: (context, state) {
          if (state is CityOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<CityBloc>().add(LoadCities(active: _activeFilter));
          } else if (state is CityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminPageHeader(
                title: 'City Management',
                subtitle: 'Manage service cities and zones',
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => _showCreateDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add City'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AdminSearchField(
                        hintText: 'Search cities...',
                        onChanged: (q) =>
                            context.read<CityBloc>().add(SearchCities(q)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _FilterDropdown(
                      value: _activeFilter,
                      onChanged: (v) {
                        setState(() => _activeFilter = v);
                        context.read<CityBloc>().add(FilterCities(v));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildContent(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CityState state) {
    if (state is CitiesLoading) {
      return const AdminLoadingSkeleton();
    }
    if (state is CityError) {
      return AdminEmptyState(
        icon: Icons.error_outline,
        message: state.message,
        description: 'Failed to load cities',
        action: ElevatedButton(
          onPressed: () =>
              context.read<CityBloc>().add(LoadCities(active: _activeFilter)),
          child: const Text('Retry'),
        ),
      );
    }
    if (state is CitiesLoaded) {
      if (state.cities.isEmpty) {
        return AdminEmptyState(
          icon: Icons.location_city_outlined,
          message: state.search != null
              ? 'No cities match your search'
              : 'No cities have been added yet',
          action: ElevatedButton(
            onPressed: () => _showCreateDialog(context),
            child: const Text('Add City'),
          ),
        );
      }
      return _CitiesTable(
        cities: state.cities,
        onCityTap: (city) => context.push('/cities/${city.id}'),
        onToggleStatus: (city) => context.read<CityBloc>().add(
              ToggleCityStatusEvent(city.id, !city.isActive),
            ),
        onDelete: (city) => _confirmDelete(context, city),
        onEdit: (city) => _showEditDialog(context, city),
      );
    }
    return const SizedBox.shrink();
  }

  void _showEditDialog(BuildContext context, CityEntity city) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CityBloc>(),
        child: Dialog(
          child: SizedBox(
            width: 600,
            child: CityForm(
              city: city,
              onUpdate: (id, params) {
                context.read<CityBloc>().add(UpdateCityEvent(id, params));
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CityEntity city) async {
    final confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete City',
      message: 'Are you sure you want to delete "${city.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true) {
      if (context.mounted) {
        context.read<CityBloc>().add(DeleteCityEvent(city.id));
      }
    }
  }
}

class _FilterDropdown extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const _FilterDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<bool?>(
          value: value,
          hint: const Text('All Status'),
          items: const [
            DropdownMenuItem(value: null, child: Text('All Status')),
            DropdownMenuItem(value: true, child: Text('Active')),
            DropdownMenuItem(value: false, child: Text('Inactive')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CitiesTable extends StatelessWidget {
  final List<CityEntity> cities;
  final ValueChanged<CityEntity> onCityTap;
  final ValueChanged<CityEntity> onToggleStatus;
  final ValueChanged<CityEntity> onDelete;
  final ValueChanged<CityEntity> onEdit;

  const _CitiesTable({
    required this.cities,
    required this.onCityTap,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
            columns: const [
              DataColumn(label: Text('City')),
              DataColumn(label: Text('State')),
              DataColumn(label: Text('Radius (km)')),
              DataColumn(label: Text('Shops'), numeric: true),
              DataColumn(label: Text('Users'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: cities.map((city) {
              return DataRow(
                onSelectChanged: (_) => onCityTap(city),
                cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          city.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${city.serviceZones.length} zones',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(city.state)),
                  DataCell(Text('${city.radius.toStringAsFixed(0)} km')),
                  DataCell(Text(city.shopCount.toString())),
                  DataCell(Text(city.userCount.toString())),
                  DataCell(
                    AdminStatusBadge(
                      label: city.isActive ? 'Active' : 'Inactive',
                      color: city.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          tooltip: 'Edit',
                          onPressed: () => onEdit(city),
                        ),
                        IconButton(
                          icon: Icon(
                            city.isActive ? Icons.toggle_on : Icons.toggle_off,
                            size: 18,
                            color: city.isActive ? Colors.green : Colors.grey,
                          ),
                          tooltip: city.isActive ? 'Deactivate' : 'Activate',
                          onPressed: () => onToggleStatus(city),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18,
                              color: Colors.red),
                          tooltip: 'Delete',
                          onPressed: () => onDelete(city),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
