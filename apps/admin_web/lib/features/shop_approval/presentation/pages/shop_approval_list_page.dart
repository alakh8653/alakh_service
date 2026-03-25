import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:admin_web/shared/shared.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/features/shop_approval/presentation/bloc/shop_approval_bloc.dart';
import 'package:admin_web/features/shop_approval/presentation/bloc/shop_approval_event.dart';
import 'package:admin_web/features/shop_approval/presentation/bloc/shop_approval_state.dart';
import 'package:admin_web/features/shop_approval/presentation/widgets/approval_action_dialog.dart';

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
    return BlocProvider<ShopApprovalBloc>(
      create: (_) => GetIt.instance<ShopApprovalBloc>()
        ..add(const LoadPendingShops()),
      child: _ShopApprovalListView(showPending: showPending),
    );
  }
}

class _ShopApprovalListView extends StatefulWidget {
  final bool showPending;

  const _ShopApprovalListView({this.showPending = false});

  @override
  State<_ShopApprovalListView> createState() => _ShopApprovalListViewState();
}

class _ShopApprovalListViewState extends State<_ShopApprovalListView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (!widget.showPending) {
      _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Shop Approval',
      body: BlocConsumer<ShopApprovalBloc, ShopApprovalState>(
        listener: (context, state) {
          if (state is ShopOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ShopApprovalBloc>().add(const LoadPendingShops());
          } else if (state is ShopApprovalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PendingShopsLoaded) {
            setState(() => _pendingCount = state.shops.length);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminPageHeader(
                title: 'Shop Approval',
                subtitle: 'Review and approve shop registrations',
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  onTap: (index) {
                    if (index == 0) {
                      context
                          .read<ShopApprovalBloc>()
                          .add(const LoadPendingShops());
                    } else {
                      context
                          .read<ShopApprovalBloc>()
                          .add(const LoadAllShops());
                    }
                  },
                  tabs: [
                    Tab(text: 'Pending ($_pendingCount)'),
                    const Tab(text: 'All Shops'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AdminSearchField(
                        hintText: 'Search shops...',
                        onChanged: (q) => context
                            .read<ShopApprovalBloc>()
                            .add(SearchShops(q)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _StatusFilterDropdown(
                      onChanged: (status) => context
                          .read<ShopApprovalBloc>()
                          .add(FilterByStatus(status)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildPendingTab(context, state),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildAllShopsTab(context, state),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPendingTab(BuildContext context, ShopApprovalState state) {
    if (state is ShopsLoading) return const AdminLoadingSkeleton();
    if (state is ShopApprovalError) {
      return AdminEmptyState(
        icon: Icons.error_outline,
        message: state.message,
        description: 'Failed to load shops',
        action: ElevatedButton(
          onPressed: () =>
              context.read<ShopApprovalBloc>().add(const LoadPendingShops()),
          child: const Text('Retry'),
        ),
      );
    }
    if (state is PendingShopsLoaded) {
      if (state.shops.isEmpty) {
        return const AdminEmptyState(
          icon: Icons.store_outlined,
          message: 'No Pending Shops',
          description: 'All shop approvals are up to date',
        );
      }
      return _ShopsTable(
        shops: state.shops,
        onView: (shop) => context.push('/shops/${shop.id}'),
        onApprove: (shop) => _showApproveDialog(context, shop),
        onReject: (shop) => _showRejectDialog(context, shop),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAllShopsTab(BuildContext context, ShopApprovalState state) {
    if (state is ShopsLoading) return const AdminLoadingSkeleton();
    if (state is AllShopsLoaded) {
      if (state.shops.isEmpty) {
        return const AdminEmptyState(
          icon: Icons.store_outlined,
          message: 'No Shops',
          description: 'No shops found for the current filters',
        );
      }
      return _ShopsTable(
        shops: state.shops,
        onView: (shop) => context.push('/shops/${shop.id}'),
        onApprove: (shop) => _showApproveDialog(context, shop),
        onReject: (shop) => _showRejectDialog(context, shop),
      );
    }
    return const SizedBox.shrink();
  }

  void _showApproveDialog(BuildContext context, ShopApprovalEntity shop) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ApprovalActionDialog(
        shopName: shop.shopName,
        isApproval: true,
        onConfirm: (notes) {
          context
              .read<ShopApprovalBloc>()
              .add(ApproveShopEvent(shop.id, notes: notes));
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void _showRejectDialog(BuildContext context, ShopApprovalEntity shop) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ApprovalActionDialog(
        shopName: shop.shopName,
        isApproval: false,
        onConfirm: (reason) {
          if (reason != null && reason.isNotEmpty) {
            context
                .read<ShopApprovalBloc>()
                .add(RejectShopEvent(shop.id, reason));
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }
}

class _StatusFilterDropdown extends StatefulWidget {
  final ValueChanged<ShopStatus?> onChanged;

  const _StatusFilterDropdown({required this.onChanged});

  @override
  State<_StatusFilterDropdown> createState() => _StatusFilterDropdownState();
}

class _StatusFilterDropdownState extends State<_StatusFilterDropdown> {
  ShopStatus? _value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<ShopStatus?>(
          value: _value,
          hint: const Text('All Status'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Status')),
            ...ShopStatus.values.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.displayName),
                )),
          ],
          onChanged: (v) {
            setState(() => _value = v);
            widget.onChanged(v);
          },
        ),
      ),
    );
  }
}

class _ShopsTable extends StatelessWidget {
  final List<ShopApprovalEntity> shops;
  final ValueChanged<ShopApprovalEntity> onView;
  final ValueChanged<ShopApprovalEntity> onApprove;
  final ValueChanged<ShopApprovalEntity> onReject;

  const _ShopsTable({
    required this.shops,
    required this.onView,
    required this.onApprove,
    required this.onReject,
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
    return AdminDataTable(
      columns: const [
        DataColumn(label: Text('Shop')),
        DataColumn(label: Text('Owner')),
        DataColumn(label: Text('Category')),
        DataColumn(label: Text('City')),
        DataColumn(label: Text('Submitted')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows: shops.map((shop) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                shop.shopName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => onView(shop),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(shop.ownerName),
                  Text(
                    shop.ownerPhone,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            DataCell(Text(shop.category)),
            DataCell(Text(shop.city)),
            DataCell(Text(_formatDate(shop.submittedAt))),
            DataCell(
              AdminStatusBadge(
                label: shop.status.displayName,
                color: _statusColor(shop.status),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18),
                    tooltip: 'View',
                    onPressed: () => onView(shop),
                  ),
                  if (shop.status == ShopStatus.pending ||
                      shop.status == ShopStatus.underReview) ...[
                    IconButton(
                      icon: const Icon(Icons.check_circle,
                          size: 18, color: Colors.green),
                      tooltip: 'Approve',
                      onPressed: () => onApprove(shop),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel,
                          size: 18, color: Colors.red),
                      tooltip: 'Reject',
                      onPressed: () => onReject(shop),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
