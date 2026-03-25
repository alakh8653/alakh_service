import '../../domain/entities/review_stats.dart';

class ReviewStatsModel extends ReviewStats {
  const ReviewStatsModel({
    required super.average,
    required super.total,
    required super.distribution,
  });

  factory ReviewStatsModel.fromJson(Map<String, dynamic> json) {
    final rawDist = json['distribution'] as Map<String, dynamic>? ?? {};
    final distribution = rawDist.map(
      (k, v) => MapEntry(int.parse(k), v as int),
    );
    return ReviewStatsModel(
      average: (json['average'] as num).toDouble(),
      total: json['total'] as int,
      distribution: distribution,
    );
  }

  Map<String, dynamic> toJson() => {
        'average': average,
        'total': total,
        'distribution':
            distribution.map((k, v) => MapEntry(k.toString(), v)),
      };
}
