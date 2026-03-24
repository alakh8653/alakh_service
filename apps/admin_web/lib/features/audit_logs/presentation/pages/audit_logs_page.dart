import 'package:flutter/material.dart';
import 'package:admin_web/shared/shared.dart';

class AuditLogsPage extends StatelessWidget {
  const AuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Audit Logs',
      breadcrumbs: [
        const BreadcrumbItem(label: 'Dashboard', path: '/'),
        const BreadcrumbItem(label: 'Audit Logs'),
      ],
      body: const Center(
        child: Text(
          'Audit Logs',
          style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 18),
        ),
      ),
    );
  }
}
