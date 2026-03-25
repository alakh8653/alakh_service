import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/shared/shared.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';
import 'package:admin_web/features/city_management/presentation/bloc/city_bloc.dart';
import 'package:admin_web/features/city_management/presentation/bloc/city_event.dart';
import 'package:admin_web/features/city_management/presentation/bloc/city_state.dart';
import 'package:admin_web/features/city_management/presentation/widgets/city_form.dart';

class CityDetailPage extends StatelessWidget {
  final String cityId;

  const CityDetailPage({super.key, required this.cityId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CityBloc>(
      create: (context) =>
          GetIt.instance<CityBloc>()..add(LoadCityById(cityId)),
      child: _CityDetailView(cityId: cityId),
    );
  }
}

class _CityDetailView extends StatelessWidget {
  final String cityId;

  const _CityDetailView({required this.cityId});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'City Detail',
      body: BlocConsumer<CityBloc, CityState>(
        listener: (context, state) {
          if (state is CityOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<CityBloc>().add(LoadCityById(cityId));
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
          if (state is CityDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CityError) {
            return Center(
              child: AdminEmptyState(
                icon: Icons.error_outline,
                message: state.message,
                description: 'Failed to load city details',
                action: ElevatedButton(
                  onPressed: () =>
                      context.read<CityBloc>().add(LoadCityById(cityId)),
                  child: const Text('Retry'),
                ),
              ),
            );
          }
          if (state is CityDetailLoaded) {
            return _CityDetailContent(city: state.city);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CityDetailContent extends StatelessWidget {
  final CityEntity city;

  const _CityDetailContent({required this.city});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: city.name,
            subtitle: '${city.state}, ${city.country}',
            actions: [
              OutlinedButton.icon(
                onPressed: () => _showEditDialog(context),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Total Shops',
                  value: city.shopCount.toString(),
                  icon: Icons.store,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Total Users',
                  value: city.userCount.toString(),
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Service Radius',
                  value: '${city.radius.toStringAsFixed(0)} km',
                  icon: Icons.radar,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Service Zones',
                  value: city.serviceZones.length.toString(),
                  icon: Icons.map,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _CityInfoCard(city: city),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MapPreviewCard(city: city),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ServiceZonesCard(zones: city.serviceZones),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
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

  void _confirmDelete(BuildContext context) async {
    final confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete City',
      message:
          'Are you sure you want to delete "${city.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<CityBloc>().add(DeleteCityEvent(city.id));
    }
  }
}

class _CityInfoCard extends StatelessWidget {
  final CityEntity city;

  const _CityInfoCard({required this.city});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _InfoRow(label: 'Name', value: city.name),
            _InfoRow(label: 'State', value: city.state),
            _InfoRow(label: 'Country', value: city.country),
            _InfoRow(
              label: 'Coordinates',
              value:
                  '${city.latitude.toStringAsFixed(4)}, ${city.longitude.toStringAsFixed(4)}',
            ),
            _InfoRow(label: 'Service Radius', value: '${city.radius} km'),
            _InfoRow(
              label: 'Status',
              value: city.isActive ? 'Active' : 'Inactive',
              valueColor: city.isActive ? Colors.green : Colors.grey,
            ),
            _InfoRow(
              label: 'Created',
              value: _formatDate(city.createdAt),
            ),
            _InfoRow(
              label: 'Last Updated',
              value: _formatDate(city.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  final CityEntity city;

  const _MapPreviewCard({required this.city});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Preview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Map Preview',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${city.latitude.toStringAsFixed(4)}, ${city.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceZonesCard extends StatelessWidget {
  final List<String> zones;

  const _ServiceZonesCard({required this.zones});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Zones (${zones.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            if (zones.isEmpty)
              const Text(
                'No service zones defined',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: zones
                    .map((zone) => Chip(
                          label: Text(zone),
                          backgroundColor: Colors.blue.shade50,
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
