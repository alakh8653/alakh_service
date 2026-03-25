import 'package:flutter/material.dart';
import 'package:admin_web/shared/shared.dart';

class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Analytics Dashboard',
      breadcrumbs: [
        const BreadcrumbItem(label: 'Dashboard'),
      ],
      body: const Center(
        child: Text(
          'Analytics Dashboard',
          style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 18),
        ),
      ),
    );
  }
}
