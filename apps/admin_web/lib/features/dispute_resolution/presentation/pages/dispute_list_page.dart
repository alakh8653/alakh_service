import 'package:flutter/material.dart';
import 'package:admin_web/shared/shared.dart';

class DisputeListPage extends StatelessWidget {
  final String? detailId;

  const DisputeListPage({super.key, this.detailId});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dispute Resolution',
      breadcrumbs: [
        const BreadcrumbItem(label: 'Dashboard', path: '/'),
        const BreadcrumbItem(label: 'Disputes'),
      ],
      body: const Center(
        child: Text(
          'Dispute Resolution',
          style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 18),
        ),
      ),
    );
  }
}
