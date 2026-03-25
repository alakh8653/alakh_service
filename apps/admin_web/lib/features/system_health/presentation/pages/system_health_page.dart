import 'package:flutter/material.dart';
import 'package:admin_web/shared/shared.dart';

class SystemHealthPage extends StatelessWidget {
  const SystemHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'System Health',
      breadcrumbs: [
        const BreadcrumbItem(label: 'Dashboard', path: '/'),
        const BreadcrumbItem(label: 'System Health'),
      ],
      body: const Center(
        child: Text(
          'System Health',
          style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 18),
        ),
      ),
    );
  }
}
