import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// A modal bottom sheet that lets the user configure [SearchFilters].
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  final SearchFilters initialFilters;
  final void Function(SearchFilters filters) onApply;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late double _minRating;
  late double _maxDistanceKm;
  late String _sortBy;
  late bool _openNow;

  static const double _priceMax = 10000;
  static const double _distanceMax = 50;
  static const List<String> _sortOptions = [
    'relevance',
    'rating',
    'distance',
    'price'
  ];

  @override
  void initState() {
    super.initState();
    _minPrice = widget.initialFilters.minPrice ?? 0;
    _maxPrice = widget.initialFilters.maxPrice ?? _priceMax;
    _minRating = widget.initialFilters.minRating ?? 0;
    _maxDistanceKm = widget.initialFilters.maxDistanceKm ?? _distanceMax;
    _sortBy = widget.initialFilters.sortBy;
    _openNow = widget.initialFilters.openNow;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filters',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const Divider(),
            const _SectionLabel('Price Range'),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: _priceMax,
              divisions: 100,
              labels: RangeLabels(
                '₹${_minPrice.round()}',
                '₹${_maxPrice.round()}',
              ),
              onChanged: (v) => setState(() {
                _minPrice = v.start;
                _maxPrice = v.end;
              }),
            ),
            const _SectionLabel('Minimum Rating'),
            Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 10,
              label: _minRating.toStringAsFixed(1),
              onChanged: (v) => setState(() => _minRating = v),
            ),
            const _SectionLabel('Max Distance (km)'),
            Slider(
              value: _maxDistanceKm,
              min: 1,
              max: _distanceMax,
              divisions: 49,
              label: '${_maxDistanceKm.round()} km',
              onChanged: (v) => setState(() => _maxDistanceKm = v),
            ),
            const _SectionLabel('Sort By'),
            Wrap(
              spacing: 8,
              children: _sortOptions
                  .map(
                    (o) => ChoiceChip(
                      label: Text(o[0].toUpperCase() + o.substring(1)),
                      selected: _sortBy == o,
                      onSelected: (_) => setState(() => _sortBy = o),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Open Now'),
              value: _openNow,
              onChanged: (v) => setState(() => _openNow = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apply,
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _minPrice = 0;
      _maxPrice = _priceMax;
      _minRating = 0;
      _maxDistanceKm = _distanceMax;
      _sortBy = 'relevance';
      _openNow = false;
    });
  }

  void _apply() {
    widget.onApply(SearchFilters(
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < _priceMax ? _maxPrice : null,
      minRating: _minRating > 0 ? _minRating : null,
      maxDistanceKm: _maxDistanceKm < _distanceMax ? _maxDistanceKm : null,
      sortBy: _sortBy,
      openNow: _openNow,
    ));
    Navigator.of(context).pop();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
