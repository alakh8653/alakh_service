import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:admin_web/shared/widgets/admin_empty_state.dart';
import 'package:admin_web/shared/widgets/admin_loading_skeleton.dart';

class AdminDataTable<T> extends StatefulWidget {
  final List<DataColumn2> columns;
  final List<DataRow2> Function(T item) rowBuilder;
  final List<T> data;
  final bool isLoading;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final void Function(int page)? onPageChanged;
  final void Function(String? column)? onSort;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rowBuilder,
    required this.data,
    this.isLoading = false,
    this.totalCount = 0,
    this.currentPage = 1,
    this.pageSize = 20,
    this.onPageChanged,
    this.onSort,
  });

  @override
  State<AdminDataTable<T>> createState() => _AdminDataTableState<T>();
}

class _AdminDataTableState<T> extends State<AdminDataTable<T>> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const AdminLoadingSkeleton(type: SkeletonType.table);
    }

    if (widget.data.isEmpty) {
      return const AdminEmptyState(
        message: 'No data found',
        description: 'There are no records to display.',
        icon: Icons.table_rows_outlined,
      );
    }

    final totalPages = (widget.totalCount / widget.pageSize).ceil();

    return Column(
      children: [
        Expanded(
          child: DataTable2(
            columns: widget.columns,
            rows: widget.data.expand(widget.rowBuilder).toList(),
            columnSpacing: 16,
            horizontalMargin: 16,
            dividerThickness: 1,
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFF21262D),
            ),
            headingRowHeight: 40,
            dataRowHeight: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
            ),
            border: TableBorder.all(
              color: const Color(0xFF30363D),
              width: 1,
            ),
            empty: const AdminEmptyState(
              message: 'No data',
              icon: Icons.inbox_outlined,
            ),
          ),
        ),
        if (widget.totalCount > widget.pageSize)
          _PaginationBar(
            currentPage: widget.currentPage,
            totalPages: totalPages,
            totalCount: widget.totalCount,
            pageSize: widget.pageSize,
            onPageChanged: widget.onPageChanged,
          ),
      ],
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final void Function(int)? onPageChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final start = (currentPage - 1) * pageSize + 1;
    final end = (currentPage * pageSize).clamp(0, totalCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(top: BorderSide(color: Color(0xFF30363D))),
      ),
      child: Row(
        children: [
          Text(
            'Showing $start–$end of $totalCount',
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.first_page, size: 18),
            onPressed: currentPage > 1 ? () => onPageChanged?.call(1) : null,
            color: const Color(0xFF8B949E),
            tooltip: 'First page',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 18),
            onPressed:
                currentPage > 1 ? () => onPageChanged?.call(currentPage - 1) : null,
            color: const Color(0xFF8B949E),
            tooltip: 'Previous page',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$currentPage / $totalPages',
              style: const TextStyle(
                color: Color(0xFFC9D1D9),
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18),
            onPressed: currentPage < totalPages
                ? () => onPageChanged?.call(currentPage + 1)
                : null,
            color: const Color(0xFF8B949E),
            tooltip: 'Next page',
          ),
          IconButton(
            icon: const Icon(Icons.last_page, size: 18),
            onPressed: currentPage < totalPages
                ? () => onPageChanged?.call(totalPages)
                : null,
            color: const Color(0xFF8B949E),
            tooltip: 'Last page',
          ),
        ],
      ),
    );
  }
}
