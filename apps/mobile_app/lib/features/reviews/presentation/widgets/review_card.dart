import 'package:flutter/material.dart';
import '../../domain/entities/review.dart';
import 'star_rating_display.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onTap;
  final VoidCallback? onHelpful;
  final VoidCallback? onReport;

  const ReviewCard({
    super.key,
    required this.review,
    this.onTap,
    this.onHelpful,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: review.userAvatar != null
                        ? NetworkImage(review.userAvatar!)
                        : null,
                    child: review.userAvatar == null
                        ? Text(review.userName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          _formatDate(review.createdAt),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  StarRatingDisplay(rating: review.rating, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              if (review.title.isNotEmpty)
                Text(review.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(review.text, maxLines: 3, overflow: TextOverflow.ellipsis),
              if (review.photos.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(review.photos[i],
                          width: 60, height: 60, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
              const Divider(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onHelpful,
                    icon: const Icon(Icons.thumb_up_outlined, size: 16),
                    label: Text('${review.helpfulCount} Helpful'),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600]),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onReport,
                    icon: const Icon(Icons.flag_outlined, size: 16),
                    label: const Text('Report'),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600]),
                  ),
                ],
              ),
              if (review.ownerResponse != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Response from ${review.ownerResponse!.ownerName}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(review.ownerResponse!.content,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}
