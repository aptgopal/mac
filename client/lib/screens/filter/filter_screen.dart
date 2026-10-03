import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double _minPrice = 0;
  double _maxPrice = 1000;
  int _stars = 0;
  String _propertyType = 'All';

  final List<String> _propertyTypes = ['All', 'Hotel', 'Lodge', 'Apartment', 'Villa'];
  final List<int> _starOptions = [0, 1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Filter'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _minPrice = 0;
                _maxPrice = 1000;
                _stars = 0;
                _propertyType = 'All';
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Price Range',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels('\$${_minPrice.round()}', '\$${_maxPrice.round()}'),
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${_minPrice.round()}', style: theme.textTheme.bodyMedium),
                Text('\$${_maxPrice.round()}', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Star Rating',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _starOptions.map((star) {
              final isSelected = _stars == star;
              return ChoiceChip(
                label: Text(star == 0 ? 'Any' : '$star Star${star > 1 ? "s" : ""}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _stars = selected ? star : 0);
                },
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Property Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _propertyTypes.map((type) {
              final isSelected = _propertyType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _propertyType = selected ? type : 'All');
                },
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'minPrice': _minPrice,
                  'maxPrice': _maxPrice,
                  'stars': _stars,
                  'propertyType': _propertyType,
                });
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
