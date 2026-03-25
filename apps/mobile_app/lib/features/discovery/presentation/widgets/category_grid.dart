import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// A scrollable grid of [Category] items, each showing an icon and label.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.crossAxisCount = 4,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Category> categories;
  final void Function(Category category) onCategoryTap;
  final int crossAxisCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final sorted = [...categories]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) =>
          _CategoryItem(category: sorted[index], onTap: onCategoryTap),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.onTap,
  });

  final Category category;
  final void Function(Category) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onTap(category),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: category.iconUrl.startsWith('http')
                ? ClipOval(
                    child: Image.network(
                    category.iconUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.category, color: Colors.grey),
                  ))
                : Icon(Icons.category, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
