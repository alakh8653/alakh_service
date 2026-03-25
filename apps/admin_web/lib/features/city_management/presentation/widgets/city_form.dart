import 'package:flutter/material.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';

class CityForm extends StatefulWidget {
  final CityEntity? city;
  final void Function(CreateCityParams params)? onSubmit;
  final void Function(String id, UpdateCityParams params)? onUpdate;

  const CityForm({
    super.key,
    this.city,
    this.onSubmit,
    this.onUpdate,
  });

  @override
  State<CityForm> createState() => _CityFormState();
}

class _CityFormState extends State<CityForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _radiusController = TextEditingController();
  final _zonesController = TextEditingController();

  bool get _isEditing => widget.city != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.city!.name;
      _stateController.text = widget.city!.state;
      _countryController.text = widget.city!.country;
      _latController.text = widget.city!.latitude.toString();
      _lngController.text = widget.city!.longitude.toString();
      _radiusController.text = widget.city!.radius.toString();
      _zonesController.text = widget.city!.serviceZones.join(', ');
    } else {
      _countryController.text = 'India';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    _zonesController.dispose();
    super.dispose();
  }

  List<String> _parseZones(String text) {
    return text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final zones = _parseZones(_zonesController.text);

    if (_isEditing) {
      final params = UpdateCityParams(
        name: _nameController.text,
        state: _stateController.text,
        country: _countryController.text,
        latitude: double.tryParse(_latController.text),
        longitude: double.tryParse(_lngController.text),
        radius: double.tryParse(_radiusController.text),
        serviceZones: zones,
      );
      widget.onUpdate?.call(widget.city!.id, params);
    } else {
      final params = CreateCityParams(
        name: _nameController.text,
        state: _stateController.text,
        country: _countryController.text,
        latitude: double.parse(_latController.text),
        longitude: double.parse(_lngController.text),
        radius: double.parse(_radiusController.text),
        serviceZones: zones,
      );
      widget.onSubmit?.call(params);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Edit City' : 'Add New City',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _nameController,
                    label: 'City Name',
                    hint: 'e.g., Mumbai',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'City name is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'e.g., Maharashtra',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'State is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _countryController,
              label: 'Country',
              hint: 'India',
              validator: (v) =>
                  v == null || v.isEmpty ? 'Country is required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _latController,
                    label: 'Latitude',
                    hint: 'e.g., 19.0760',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lngController,
                    label: 'Longitude',
                    hint: 'e.g., 72.8777',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _radiusController,
                    label: 'Service Radius (km)',
                    hint: 'e.g., 50',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _zonesController,
              label: 'Service Zones (comma-separated)',
              hint: 'Zone A, Zone B, North Zone',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isEditing ? 'Update City' : 'Create City'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
