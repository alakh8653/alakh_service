import 'package:flutter/material.dart';

enum EmptyStatePreset { noData, noResults, noPermission, error }

class AdminEmptyState extends StatelessWidget {
  final String message;
  final String? description;
  final IconData? icon;
  final Widget? action;
  final EmptyStatePreset? preset;

  const AdminEmptyState({
    super.key,
    this.message = 'No data',
    this.description,
    this.icon,
    this.action,
    this.preset,
  });

  factory AdminEmptyState.noData({Widget? action}) => AdminEmptyState(
        preset: EmptyStatePreset.noData,
        message: 'No data available',
        description: 'There are no records to display at this time.',
        icon: Icons.inbox_outlined,
        action: action,
      );

  factory AdminEmptyState.noResults({Widget? action}) => AdminEmptyState(
        preset: EmptyStatePreset.noResults,
        message: 'No results found',
        description: 'Try adjusting your search or filter criteria.',
        icon: Icons.search_off_outlined,
        action: action,
      );

  factory AdminEmptyState.noPermission() => const AdminEmptyState(
        preset: EmptyStatePreset.noPermission,
        message: 'Access denied',
        description: 'You do not have permission to view this content.',
        icon: Icons.lock_outline,
      );

  factory AdminEmptyState.error({String? message, Widget? action}) =>
      AdminEmptyState(
        preset: EmptyStatePreset.error,
        message: message ?? 'Something went wrong',
        description: 'An error occurred. Please try again.',
        icon: Icons.error_outline,
        action: action,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayIcon = icon ?? Icons.inbox_outlined;

    Color iconColor;
    switch (preset) {
      case EmptyStatePreset.error:
        iconColor = const Color(0xFFF85149);
      case EmptyStatePreset.noPermission:
        iconColor = const Color(0xFFD29922);
      default:
        iconColor = const Color(0xFF8B949E);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(displayIcon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFC9D1D9),
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
