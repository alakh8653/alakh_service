/// Export button with CSV, PDF, and optional Excel format options.
library;

import 'package:flutter/material.dart';

/// A compact icon button that opens a popup menu with export-format choices.
///
/// Invoke [onExportCsv], [onExportPdf], or the optional [onExportExcel]
/// callbacks depending on the user's selection.
class ExportButton extends StatelessWidget {
  /// Creates an [ExportButton].
  const ExportButton({
    required this.onExportCsv,
    required this.onExportPdf,
    this.onExportExcel,
    super.key,
  });

  /// Called when the user selects "Export as CSV".
  final VoidCallback onExportCsv;

  /// Called when the user selects "Export as PDF".
  final VoidCallback onExportPdf;

  /// Optional callback for "Export as Excel".  The menu item is hidden when
  /// this is `null`.
  final VoidCallback? onExportExcel;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ExportFormat>(
      tooltip: 'Export',
      position: PopupMenuPosition.under,
      onSelected: (format) {
        switch (format) {
          case _ExportFormat.csv:
            onExportCsv();
          case _ExportFormat.pdf:
            onExportPdf();
          case _ExportFormat.excel:
            onExportExcel?.call();
        }
      },
      itemBuilder: (_) => [
        _buildItem(
          value: _ExportFormat.csv,
          icon: Icons.table_chart_outlined,
          label: 'Export as CSV',
        ),
        _buildItem(
          value: _ExportFormat.pdf,
          icon: Icons.picture_as_pdf_outlined,
          label: 'Export as PDF',
        ),
        if (onExportExcel != null)
          _buildItem(
            value: _ExportFormat.excel,
            icon: Icons.grid_on_outlined,
            label: 'Export as Excel',
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download_rounded, size: 18),
            const SizedBox(width: 6),
            const Text('Export', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<_ExportFormat> _buildItem({
    required _ExportFormat value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}

enum _ExportFormat { csv, pdf, excel }
