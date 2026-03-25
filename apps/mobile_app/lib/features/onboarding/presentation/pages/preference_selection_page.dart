import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Page where users choose which service categories they are interested in.
///
/// Displayed as part of the onboarding flow before the final completion step.
class PreferenceSelectionPage extends StatefulWidget {
  /// Route name for named navigation.
  static const routeName = '/onboarding/preferences';

  const PreferenceSelectionPage({super.key});

  @override
  State<PreferenceSelectionPage> createState() =>
      _PreferenceSelectionPageState();
}

class _PreferenceSelectionPageState extends State<PreferenceSelectionPage> {
  static const _categories = [
    _Category('Plumbing', Icons.plumbing),
    _Category('Electrical', Icons.electrical_services),
    _Category('Cleaning', Icons.cleaning_services),
    _Category('Painting', Icons.format_paint),
    _Category('Carpentry', Icons.carpenter),
    _Category('AC & HVAC', Icons.ac_unit),
    _Category('Pest Control', Icons.bug_report),
    _Category('Appliance Repair', Icons.build),
    _Category('Landscaping', Icons.grass),
    _Category('Security', Icons.security),
    _Category('Moving', Icons.local_shipping),
    _Category('Interior Design', Icons.design_services),
  ];

  final Set<String> _selected = {};

  void _toggle(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
  }

  void _onContinue() {
    final prefs = UserPreferences(
      selectedCategories: _selected.toList(),
    );
    context.read<OnboardingBloc>().add(SavePreferences(prefs));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Your Interests'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select the services you are most likely to need.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return PreferenceChip(
                      key: ValueKey(cat.label),
                      label: cat.label,
                      icon: cat.icon,
                      isSelected: _selected.contains(cat.label),
                      onTap: () => _toggle(cat.label),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              FilledButton(
                onPressed: _onContinue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selected.isEmpty ? 'Skip for now' : 'Continue',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal helper to pair a label with its icon.
class _Category {
  final String label;
  final IconData icon;

  const _Category(this.label, this.icon);
}
