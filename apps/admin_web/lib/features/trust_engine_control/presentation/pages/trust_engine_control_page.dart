import 'package:flutter/material.dart';
import 'package:admin_web/shared/shared.dart';

class TrustEngineControlPage extends StatelessWidget {
  final String? detailId;

  const TrustEngineControlPage({super.key, this.detailId});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Trust Engine Control',
      breadcrumbs: [
        const BreadcrumbItem(label: 'Dashboard', path: '/'),
        const BreadcrumbItem(label: 'Trust Engine'),
      ],
      body: const Center(
        child: Text(
          'Trust Engine Control',
          style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 18),
        ),
      ),
    );
  }
}
