import 'package:flutter/material.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/shared/shared.dart';

class ShopApprovalCard extends StatelessWidget {
  final ShopApprovalEntity shop;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onView;

  const ShopApprovalCard({
    super.key,
    required this.shop,
    this.onApprove,
    this.onReject,
    this.onView,
  });

  Color _statusColor(ShopStatus status) {
    switch (status) {
      case ShopStatus.pending:
        return Colors.orange;
      case ShopStatus.underReview:
        return Colors.blue;
      case ShopStatus.approved:
        return Colors.green;
      case ShopStatus.rejected:
        return Colors.red;
      case ShopStatus.suspended:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.store, size: 20, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shop.shopName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  AdminStatusBadge(
                    label: shop.status.displayName,
                    color: _statusColor(shop.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${shop.ownerName} • ${shop.ownerPhone}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '${shop.category} • ${shop.city}, ${shop.state}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Submitted: ${_formatDate(shop.submittedAt)}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              if (onApprove != null || onReject != null) ...[
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onReject != null)
                      OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.cancel,
                            size: 16, color: Colors.red),
                        label: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (onApprove != null)
                      ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
