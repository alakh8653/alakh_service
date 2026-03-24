import 'package:flutter/material.dart';
import 'package:admin_web/shared/shared.dart';

class CityListPage extends StatelessWidget {
  final String? detailId;
  final bool showCreateForm;

  const CityListPage({
    super.key,
    this.detailId,
    this.showCreateForm = false,
  });

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'City Management',
      breadcrumbs: [
        const BreadcrumbItem(label: 'Dashboard', path: '/'),
        const BreadcrumbItem(label: 'Cities'),
      ],
      body: const Center(
        child: Text(
          'City Management',
          style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 18),
        ),
      ),
    );
  }
}
