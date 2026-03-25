import 'package:flutter/material.dart';

class ResolutionForm extends StatefulWidget {
  final String disputeId;
  final void Function(String resolution) onSubmit;

  const ResolutionForm({
    super.key,
    required this.disputeId,
    required this.onSubmit,
  });

  @override
  State<ResolutionForm> createState() => _ResolutionFormState();
}

class _ResolutionFormState extends State<ResolutionForm> {
  final _formKey = GlobalKey<FormState>();
  final _resolutionController = TextEditingController();
  final _refundController = TextEditingController();
  final _notesController = TextEditingController();
  bool _includeRefund = false;

  @override
  void dispose() {
    _resolutionController.dispose();
    _refundController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final buffer = StringBuffer(_resolutionController.text.trim());
    if (_includeRefund && _refundController.text.trim().isNotEmpty) {
      buffer.write(
          '\n\nRefund Amount: ₹${_refundController.text.trim()}');
    }
    if (_notesController.text.trim().isNotEmpty) {
      buffer.write('\n\nAdditional Notes: ${_notesController.text.trim()}');
    }

    widget.onSubmit(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gavel, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Resolve Dispute',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution Details *',
                hintText:
                    'Describe how the dispute was resolved...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? 'Resolution details are required'
                      : null,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _includeRefund,
              onChanged: (v) => setState(() => _includeRefund = v ?? false),
              title: const Text('Include Refund'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_includeRefund) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _refundController,
                decoration: const InputDecoration(
                  labelText: 'Refund Amount (₹)',
                  hintText: 'e.g., 500.00',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (!_includeRefund) return null;
                  if (v == null || v.isEmpty) return 'Amount required';
                  if (double.tryParse(v) == null) return 'Invalid amount';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Resolved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
