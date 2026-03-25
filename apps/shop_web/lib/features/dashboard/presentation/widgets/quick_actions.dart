import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_web/shared/shared.dart';

/// Grid of quick-action buttons allowing operators to jump to common tasks.
///
/// Uses [GoRouter] for navigation, ensuring deep-link compatibility.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const _actions = [
    _ActionConfig(
      icon: Icons.add_circle_outline_rounded,
      label: 'Add Booking',
      route: '/bookings/new',
      color: Colors.blue,
    ),
    _ActionConfig(
      icon: Icons.queue_rounded,
      label: 'Manage Queue',
      route: '/queue',
      color: Colors.orange,
    ),
    _ActionConfig(
      icon: Icons.bar_chart_rounded,
      label: 'View Earnings',
      route: '/earnings',
      color: Colors.green,
    ),
    _ActionConfig(
      icon: Icons.person_add_alt_1_rounded,
      label: 'Invite Staff',
      route: '/staff/invite',
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: _actions
                .map((cfg) => _ActionButton(config: cfg))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final _ActionConfig config;

  const _ActionButton({required this.config});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(config.route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: config.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: config.color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(config.icon, size: 28, color: config.color),
            const SizedBox(height: 6),
            Text(
              config.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: config.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionConfig {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const _ActionConfig({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}
