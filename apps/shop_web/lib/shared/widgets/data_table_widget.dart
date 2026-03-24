/// Generic sortable data-table with pagination, search, and selection.
library;

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shop_web/shared/widgets/empty_table_state.dart';
import 'package:shop_web/shared/widgets/loading_table.dart';

/// Defines a single column for [ShopDataTable].
class ShopDataColumn {
  /// Creates a [ShopDataColumn].
  const ShopDataColumn({
    required this.label,
    required this.dataCell,
    this.sortable = false,
    this.columnWidth = ColumnSize.M,
  });

  /// Column header label.
  final String label;

  /// Builds the [DataCell] for each row item.
  final DataCell Function(dynamic item) dataCell;

  /// Whether the column supports sorting.
  final bool sortable;

  /// Relative column width hint for [DataTable2].
  final ColumnSize columnWidth;
}

/// A generic data table widget with pagination, search, selection, and
/// loading / empty states.
///
/// Type parameter [T] is the row data model.
class ShopDataTable<T> extends StatefulWidget {
  /// Creates a [ShopDataTable].
  const ShopDataTable({
    required this.items,
    required this.columns,
    required this.onRowTap,
    required this.totalItems,
    required this.currentPage,
    required this.onPageChanged,
    required this.onSearch,
    this.isLoading = false,
    this.selectedItems = const [],
    this.onSelectionChanged,
    this.selectable = false,
    this.pageSize = 20,
    super.key,
  });

  /// The current page of data.
  final List<T> items;

  /// Column definitions.
  final List<ShopDataColumn> columns;

  /// Called when a row is tapped.
  final void Function(T item) onRowTap;

  /// Whether the table is in a loading state.
  final bool isLoading;

  /// Total number of items across all pages.
  final int totalItems;

  /// The current 1-based page index.
  final int currentPage;

  /// Called when the user navigates to a different page.
  final void Function(int page) onPageChanged;

  /// Called when the user types in the search field.
  final void Function(String query) onSearch;

  /// Currently selected items.
  final List<T> selectedItems;

  /// Called when selection changes (only used if [selectable] is `true`).
  final void Function(List<T> items)? onSelectionChanged;

  /// Whether rows can be selected via checkboxes.
  final bool selectable;

  /// Number of rows per page.
  final int pageSize;

  @override
  State<ShopDataTable<T>> createState() => _ShopDataTableState<T>();
}

class _ShopDataTableState<T> extends State<ShopDataTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalPages => (widget.totalItems / widget.pageSize).ceil().clamp(1, 999999);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchBar(
          controller: _searchController,
          onSearch: widget.onSearch,
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildTable(theme)),
        _PaginationBar(
          currentPage: widget.currentPage,
          totalPages: _totalPages,
          totalItems: widget.totalItems,
          onPageChanged: widget.onPageChanged,
        ),
      ],
    );
  }

  Widget _buildTable(ThemeData theme) {
    if (widget.isLoading) {
      return LoadingTable(
        rowCount: widget.pageSize.clamp(5, 10),
        columnCount: widget.columns.length,
      );
    }

    if (widget.items.isEmpty) {
      return const EmptyTableState(
        message: 'No records found.',
        icon: Icons.table_rows_outlined,
      );
    }

    return DataTable2(
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      showCheckboxColumn: widget.selectable,
      headingRowColor: WidgetStateProperty.all(
        theme.colorScheme.surfaceContainerHighest,
      ),
      border: TableBorder.symmetric(
        inside: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      columns: _buildColumns(),
      rows: _buildRows(),
    );
  }

  List<DataColumn2> _buildColumns() {
    return List.generate(widget.columns.length, (i) {
      final col = widget.columns[i];
      return DataColumn2(
        label: Text(
          col.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        size: col.columnWidth,
        onSort: col.sortable
            ? (colIdx, ascending) => setState(() {
                  _sortColumnIndex = colIdx;
                  _sortAscending = ascending;
                })
            : null,
      );
    });
  }

  List<DataRow2> _buildRows() {
    return widget.items.map((item) {
      final isSelected = widget.selectedItems.contains(item);
      return DataRow2(
        selected: isSelected,
        onSelectChanged: widget.selectable
            ? (selected) {
                final updated = List<T>.from(widget.selectedItems);
                if (selected == true) {
                  updated.add(item);
                } else {
                  updated.remove(item);
                }
                widget.onSelectionChanged?.call(updated);
              }
            : null,
        onTap: () => widget.onRowTap(item),
        cells: widget.columns.map((col) => col.dataCell(item)).toList(),
      );
    }).toList();
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final void Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onSearch,
      decoration: InputDecoration(
        hintText: 'Search…',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  controller.clear();
                  onSearch('');
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$totalItems result${totalItems == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              ),
              Text('$currentPage / $totalPages', style: theme.textTheme.bodySmall),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
