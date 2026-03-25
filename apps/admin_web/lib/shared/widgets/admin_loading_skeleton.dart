import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

enum SkeletonType { table, card, list, chart, form }

class AdminLoadingSkeleton extends StatelessWidget {
  final SkeletonType type;
  final int? itemCount;

  const AdminLoadingSkeleton({
    super.key,
    required this.type,
    this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF21262D),
      highlightColor: const Color(0xFF30363D),
      child: _buildSkeleton(),
    );
  }

  Widget _buildSkeleton() {
    switch (type) {
      case SkeletonType.table:
        return _TableSkeleton(rowCount: itemCount ?? 8);
      case SkeletonType.card:
        return _CardSkeleton(count: itemCount ?? 4);
      case SkeletonType.list:
        return _ListSkeleton(count: itemCount ?? 6);
      case SkeletonType.chart:
        return _ChartSkeleton();
      case SkeletonType.form:
        return _FormSkeleton(fieldCount: itemCount ?? 4);
    }
  }
}

class _TableSkeleton extends StatelessWidget {
  final int rowCount;

  const _TableSkeleton({required this.rowCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 1),
        ),
        ...List.generate(
          rowCount,
          (i) => Container(
            height: 48,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 1),
          ),
        ),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  final int count;

  const _CardSkeleton({required this.count});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        childAspectRatio: 1.4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: count,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  final int count;

  const _ListSkeleton({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormSkeleton extends StatelessWidget {
  final int fieldCount;

  const _FormSkeleton({required this.fieldCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        fieldCount,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
