import 'package:flutter/material.dart';
import '../../domain/entities/dispute_evidence.dart';

class EvidenceUploadWidget extends StatelessWidget {
  final Function(EvidenceType, String) onUpload;

  const EvidenceUploadWidget({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _UploadButton(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: () => onUpload(EvidenceType.photo, 'camera'),
            ),
            _UploadButton(
              icon: Icons.photo_library,
              label: 'Gallery',
              onTap: () => onUpload(EvidenceType.photo, 'gallery'),
            ),
            _UploadButton(
              icon: Icons.videocam,
              label: 'Video',
              onTap: () => onUpload(EvidenceType.video, 'video'),
            ),
            _UploadButton(
              icon: Icons.text_fields,
              label: 'Text',
              onTap: () => onUpload(EvidenceType.text, 'text'),
            ),
          ],
        ),
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
