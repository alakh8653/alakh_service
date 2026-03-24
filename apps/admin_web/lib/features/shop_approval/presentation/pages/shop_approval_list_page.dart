import 'package:flutter/material.dart';
import 'package:admin_web/shared/shared.dart';

class ShopApprovalListPage extends StatelessWidget {
  final String? detailId;
  final bool showPending;

  const ShopApprovalListPage({
    super.key,
    this.detailId,
    this.showPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: showPending ? 'Pending Shop Approvals' : 'Shop Management',
      breadcrumbs: [
        const BreadcrumbItem(label: 'Dashboard', path: '/'),
        const BreadcrumbItem(label: 'Shops'),
      ],
      body: const Center(
        child: Text(
          'Shop Approval',
          style: TextStyle(color: Color(0xFFC9D1D9), fontSize: 18),
        ),
      ),
    );
  }
}
