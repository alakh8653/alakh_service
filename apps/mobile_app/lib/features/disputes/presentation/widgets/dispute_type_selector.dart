import 'package:flutter/material.dart';
import '../../domain/entities/dispute_type.dart';

class DisputeTypeSelector extends StatelessWidget {
  final DisputeType? selectedType;
  final ValueChanged<DisputeType> onSelected;

  const DisputeTypeSelector({
    super.key,
    this.selectedType,
    required this.onSelected,
  });

  IconData _iconForType(DisputeType type) {
    switch (type) {
      case DisputeType.serviceQuality: return Icons.star_border;
      case DisputeType.overcharge: return Icons.attach_money;
      case DisputeType.noShow: return Icons.person_off;
      case DisputeType.wrongService: return Icons.error_outline;
      case DisputeType.damagedProperty: return Icons.broken_image;
      case DisputeType.unprofessionalBehavior: return Icons.warning_amber;
      case DisputeType.other: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      children: DisputeType.values.map((type) {
        final isSelected = selectedType == type;
        return InkWell(
          onTap: () => onSelected(type),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_iconForType(type),
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey[600],
                    size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    type.displayName,
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
