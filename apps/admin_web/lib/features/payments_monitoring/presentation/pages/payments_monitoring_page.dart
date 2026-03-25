import 'package:flutter/material.dart';
import 'package:admin_web/shared/shared.dart';

class PaymentsMonitoringPage extends StatelessWidget {
  final String? detailId;

  const PaymentsMonitoringPage({super.key, this.detailId});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Payments Monitoring',
      breadcrumbs: [
        const BreadcrumbItem(label: 'Dashboard', path: '/'),
        const BreadcrumbItem(label: 'Payments'),
      ],
      body: const Center(
        child: Text(
          'Payments Monitoring',
          style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 18),
        ),
      ),
    );
  }
}
