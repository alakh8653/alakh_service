import 'package:flutter/material.dart';

/// Displays a compact summary row for a service.
class ServiceSummaryWidget extends StatelessWidget {
  final String serviceName;
  final int durationMinutes;
  final double price;
  final IconData icon;

  const ServiceSummaryWidget({
    super.key,
    required this.serviceName,
    required this.durationMinutes,
    required this.price,
    this.icon = Icons.design_services_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(serviceName,
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text('$durationMinutes min',
                  style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
