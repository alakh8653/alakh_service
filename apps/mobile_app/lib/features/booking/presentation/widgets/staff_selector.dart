import 'package:flutter/material.dart';

/// A staff member displayed in the [StaffSelector].
class StaffItem {
  final String id;
  final String name;
  final String? avatarUrl;

  const StaffItem({required this.id, required this.name, this.avatarUrl});
}

/// A horizontally scrollable row of staff avatars.
///
/// The selected staff member is highlighted. Tapping an avatar fires
/// [onStaffSelected] with the chosen [StaffItem].
class StaffSelector extends StatelessWidget {
  final List<StaffItem> staffList;
  final String? selectedStaffId;
  final ValueChanged<StaffItem?> onStaffSelected;

  const StaffSelector({
    super.key,
    required this.staffList,
    required this.onStaffSelected,
    this.selectedStaffId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Select Staff (optional)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: staffList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final staff = staffList[index];
              final isSelected = staff.id == selectedStaffId;
              return _StaffAvatar(
                staff: staff,
                isSelected: isSelected,
                onTap: () {
                  // Tapping the already-selected staff deselects.
                  onStaffSelected(isSelected ? null : staff);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StaffAvatar extends StatelessWidget {
  final StaffItem staff;
  final bool isSelected;
  final VoidCallback onTap;

  const _StaffAvatar({
    required this.staff,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: staff.avatarUrl != null
                  ? NetworkImage(staff.avatarUrl!)
                  : null,
              backgroundColor: colorScheme.secondaryContainer,
              child: staff.avatarUrl == null
                  ? Text(
                      staff.name[0].toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            staff.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.primary : null,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
