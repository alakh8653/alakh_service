import 'package:flutter/material.dart';
import 'package:admin_web/shared/shared.dart';

class FraudMonitoringPage extends StatelessWidget {
  final String? detailId;

  const FraudMonitoringPage({super.key, this.detailId});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Fraud Monitoring',
      breadcrumbs: [
        const BreadcrumbItem(label: 'Dashboard', path: '/'),
        const BreadcrumbItem(label: 'Fraud'),
      ],
      body: const Center(
        child: Text(
          'Fraud Monitoring',
          style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 18),
        ),
      ),
    );
  }
}
