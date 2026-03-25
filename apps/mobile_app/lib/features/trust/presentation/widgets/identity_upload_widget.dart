import 'package:flutter/material.dart';

class IdentityUploadWidget extends StatelessWidget {
  final String label;
  final String? uploadedUrl;
  final VoidCallback onUpload;

  const IdentityUploadWidget({
    super.key,
    required this.label,
    required this.onUpload,
    this.uploadedUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUploaded = uploadedUrl != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isUploaded ? Colors.green : Colors.grey[300]!,
          width: isUploaded ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isUploaded ? Colors.green[50] : Colors.grey[50],
      ),
      child: Column(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file,
            size: 40,
            color: isUploaded ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.camera_alt, size: 16),
            label: Text(isUploaded ? 'Re-upload' : 'Upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
