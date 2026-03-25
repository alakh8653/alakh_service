import 'package:flutter/material.dart';

class ApprovalActionDialog extends StatefulWidget {
  final String shopName;
  final bool isApproval;
  final String? title;
  final String? confirmLabel;
  final String? reasonLabel;
  final void Function(String? notesOrReason) onConfirm;

  const ApprovalActionDialog({
    super.key,
    required this.shopName,
    required this.isApproval,
    required this.onConfirm,
    this.title,
    this.confirmLabel,
    this.reasonLabel,
  });

  @override
  State<ApprovalActionDialog> createState() => _ApprovalActionDialogState();
}

class _ApprovalActionDialogState extends State<ApprovalActionDialog>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool get _isApproval => widget.isApproval;
  String get _title =>
      widget.title ?? (_isApproval ? 'Approve Shop' : 'Reject Shop');
  String get _confirmLabel =>
      widget.confirmLabel ?? (_isApproval ? 'Approve' : 'Reject');
  String get _reasonLabel =>
      widget.reasonLabel ??
      (_isApproval ? 'Notes (optional)' : 'Reason for rejection *');

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _isApproval ? Icons.check_circle : Icons.cancel,
              color: _isApproval ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(_title),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: _isApproval
                          ? 'Are you sure you want to approve '
                          : 'Are you sure you want to reject ',
                    ),
                    TextSpan(
                      text: widget.shopName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _reasonLabel,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: _isApproval
                      ? 'Add notes...'
                      : 'Enter reason for rejection...',
                  isDense: true,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!_isApproval &&
                  _controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rejection reason is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              widget.onConfirm(
                  _controller.text.trim().isEmpty ? null : _controller.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isApproval ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(_confirmLabel),
          ),
        ],
      ),
    );
  }
}
