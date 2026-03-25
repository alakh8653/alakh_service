/// Shimmer skeleton loader that mimics a data table layout.
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Renders a shimmer-animated skeleton that resembles a data table with
/// [rowCount] rows and [columnCount] columns.
///
/// Use this as the [isLoading] state of [ShopDataTable] to give users a
/// realistic preview of the content structure while data is fetching.
class LoadingTable extends StatelessWidget {
  /// Creates a [LoadingTable].
  const LoadingTable({
    this.rowCount = 8,
    this.columnCount = 5,
    super.key,
  });

  /// Number of skeleton rows to render.
  final int rowCount;

  /// Number of skeleton columns per row.
  final int columnCount;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          _HeaderRow(columnCount: columnCount, baseColor: baseColor),
          const SizedBox(height: 2),
          // Data rows
          ...List.generate(
            rowCount,
            (rowIndex) => _DataRow(
              columnCount: columnCount,
              baseColor: baseColor,
              evenRow: rowIndex.isEven,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.columnCount, required this.baseColor});

  final int columnCount;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: baseColor.withOpacity(0.6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(columnCount, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < columnCount - 1 ? 16 : 0),
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.columnCount,
    required this.baseColor,
    required this.evenRow,
  });

  final int columnCount;
  final Color baseColor;
  final bool evenRow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: evenRow ? Colors.transparent : baseColor.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(columnCount, (i) {
          // Vary widths slightly for a more realistic look.
          final widthFactor = i == 0 ? 0.6 : (i % 3 == 0 ? 0.4 : 0.75);
          return Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
