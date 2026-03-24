import 'package:flutter/material.dart';
import '../../domain/entities/dispute_evidence.dart';

class EvidenceGallery extends StatelessWidget {
  final List<DisputeEvidence> evidenceList;
  final Function(DisputeEvidence)? onTap;

  const EvidenceGallery({
    super.key,
    required this.evidenceList,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (evidenceList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No evidence attached'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: evidenceList.length,
      itemBuilder: (context, index) {
        final evidence = evidenceList[index];
        return GestureDetector(
          onTap: () => onTap?.call(evidence),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: evidence.type == EvidenceType.photo ||
                    evidence.type == EvidenceType.video
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        evidence.url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[200]),
                      ),
                      if (evidence.type == EvidenceType.video)
                        const Center(
                          child: Icon(Icons.play_circle, color: Colors.white, size: 32),
                        ),
                    ],
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.description, size: 32),
                  ),
          ),
        );
      },
    );
  }
}
