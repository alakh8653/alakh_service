import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:admin_web/shared/shared.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/features/shop_approval/presentation/bloc/shop_approval_bloc.dart';
import 'package:admin_web/features/shop_approval/presentation/bloc/shop_approval_event.dart';
import 'package:admin_web/features/shop_approval/presentation/bloc/shop_approval_state.dart';
import 'package:admin_web/features/shop_approval/presentation/widgets/approval_action_dialog.dart';
import 'package:admin_web/features/shop_approval/presentation/widgets/shop_document_viewer.dart';

class ShopDetailPage extends StatelessWidget {
  final String shopId;

  const ShopDetailPage({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShopApprovalBloc>(
      create: (_) =>
          GetIt.instance<ShopApprovalBloc>()..add(LoadShopById(shopId)),
      child: _ShopDetailView(shopId: shopId),
    );
  }
}

class _ShopDetailView extends StatelessWidget {
  final String shopId;

  const _ShopDetailView({required this.shopId});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Shop Detail',
      body: BlocConsumer<ShopApprovalBloc, ShopApprovalState>(
        listener: (context, state) {
          if (state is ShopOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ShopApprovalBloc>().add(LoadShopById(shopId));
          } else if (state is ShopApprovalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShopsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ShopApprovalError) {
            return Center(
              child: AdminEmptyState(
                icon: Icons.error_outline,
                message: 'Error',
                message: state.message,
                description: 'Failed to load shop details',
                onAction: () =>
                    context.read<ShopApprovalBloc>().add(LoadShopById(shopId)),
              ),
            );
          }
          if (state is ShopDetailLoaded) {
            return _ShopDetailContent(shop: state.shop);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ShopDetailContent extends StatelessWidget {
  final ShopApprovalEntity shop;

  const _ShopDetailContent({required this.shop});

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: shop.shopName,
            subtitle: '${shop.category} • ${shop.city}, ${shop.state}',
            actions: _buildActions(context),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AdminStatusBadge(
                label: shop.status.displayName,
                color: _statusColor(shop.status),
              ),
              const SizedBox(width: 12),
              Text(
                'Submitted ${_formatDate(shop.submittedAt)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              if (shop.reviewedAt != null) ...[
                const SizedBox(width: 12),
                Text(
                  'Reviewed ${_formatDate(shop.reviewedAt!)}',
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _OwnerInfoCard(shop: shop),
                    const SizedBox(height: 16),
                    _BusinessInfoCard(shop: shop),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    MetricCard(
                      title: 'Rating',
                      value: shop.rating.toStringAsFixed(1),
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 16),
                    MetricCard(
                      title: 'Total Reviews',
                      value: shop.totalReviews.toString(),
                      icon: Icons.rate_review,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    MetricCard(
                      title: 'Documents',
                      value: shop.documents.length.toString(),
                      icon: Icons.description,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ShopDocumentViewer(documents: shop.documents),
          if (shop.rejectionReason != null) ...[
            const SizedBox(height: 24),
            _RejectionReasonCard(reason: shop.rejectionReason!),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];
    if (shop.status == ShopStatus.pending ||
        shop.status == ShopStatus.underReview) {
      actions.addAll([
        ElevatedButton.icon(
          onPressed: () => _showApproveDialog(context),
          icon: const Icon(Icons.check_circle),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _showRejectDialog(context),
          icon: const Icon(Icons.cancel, color: Colors.red),
          label: const Text(
            'Reject',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ]);
    }
    if (shop.status == ShopStatus.approved) {
      actions.add(
        OutlinedButton.icon(
          onPressed: () => _showSuspendDialog(context),
          icon: const Icon(Icons.block, color: Colors.orange),
          label: const Text(
            'Suspend',
            style: TextStyle(color: Colors.orange),
          ),
        ),
      );
    }
    return actions;
  }

  void _showApproveDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ApprovalActionDialog(
        shopName: shop.shopName,
        isApproval: true,
        onConfirm: (notes) {
          context.read<ShopApprovalBloc>().add(
                ApproveShopEvent(shop.id, notes: notes),
              );
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ApprovalActionDialog(
        shopName: shop.shopName,
        isApproval: false,
        onConfirm: (reason) {
          if (reason != null && reason.isNotEmpty) {
            context.read<ShopApprovalBloc>().add(
                  RejectShopEvent(shop.id, reason),
                );
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  void _showSuspendDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ApprovalActionDialog(
        shopName: shop.shopName,
        isApproval: false,
        title: 'Suspend Shop',
        confirmLabel: 'Suspend',
        reasonLabel: 'Reason for suspension',
        onConfirm: (reason) {
          if (reason != null && reason.isNotEmpty) {
            context
                .read<ShopApprovalBloc>()
                .add(SuspendShopEvent(shop.id, reason));
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _OwnerInfoCard extends StatelessWidget {
  final ShopApprovalEntity shop;

  const _OwnerInfoCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Owner Information',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _InfoRow(label: 'Name', value: shop.ownerName),
            _InfoRow(label: 'Phone', value: shop.ownerPhone),
            _InfoRow(label: 'Email', value: shop.ownerEmail),
          ],
        ),
      ),
    );
  }
}

class _BusinessInfoCard extends StatelessWidget {
  final ShopApprovalEntity shop;

  const _BusinessInfoCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Information',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _InfoRow(label: 'Shop Name', value: shop.shopName),
            _InfoRow(label: 'Category', value: shop.category),
            _InfoRow(label: 'Address', value: shop.address),
            _InfoRow(label: 'City', value: shop.city),
            _InfoRow(label: 'State', value: shop.state),
            if (shop.gstNumber != null)
              _InfoRow(label: 'GST Number', value: shop.gstNumber!),
            if (shop.licenseNumber != null)
              _InfoRow(label: 'License No.', value: shop.licenseNumber!),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _RejectionReasonCard extends StatelessWidget {
  final String reason;

  const _RejectionReasonCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rejection Reason',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(reason),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
