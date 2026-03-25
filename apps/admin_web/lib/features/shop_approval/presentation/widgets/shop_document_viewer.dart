import 'package:flutter/material.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';

class ShopDocumentViewer extends StatelessWidget {
  final List<ShopDocument> documents;

  const ShopDocumentViewer({super.key, required this.documents});

  IconData _iconForType(ShopDocumentType type) {
    switch (type) {
      case ShopDocumentType.gstCertificate:
        return Icons.receipt_long;
      case ShopDocumentType.businessLicense:
        return Icons.business;
      case ShopDocumentType.addressProof:
        return Icons.home;
      case ShopDocumentType.ownerIdProof:
        return Icons.badge;
      case ShopDocumentType.shopPhoto:
        return Icons.photo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents (${documents.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            if (documents.isEmpty)
              const Text(
                'No documents uploaded',
                style: TextStyle(color: Colors.grey),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: documents.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: doc.verified
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconForType(doc.type),
                        size: 20,
                        color: doc.verified ? Colors.green : Colors.orange,
                      ),
                    ),
                    title: Text(
                      doc.type.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Uploaded: ${_formatDate(doc.uploadedAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (doc.verified)
                          const Chip(
                            label: Text(
                              'Verified',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.zero,
                          )
                        else
                          const Chip(
                            label: Text(
                              'Pending',
                              style: TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.zero,
                          ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _openDocument(context, doc.url),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('View'),
                        ),
                      ],
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openDocument(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: $url')),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
