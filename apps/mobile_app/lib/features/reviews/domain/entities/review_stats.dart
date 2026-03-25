import 'package:equatable/equatable.dart';

class ReviewStats extends Equatable {
  final double average;
  final int total;
  final Map<int, int> distribution;

  const ReviewStats({
    required this.average,
    required this.total,
    required this.distribution,
  });

  int countForStar(int star) => distribution[star] ?? 0;

  double percentForStar(int star) {
    if (total == 0) return 0;
    return (distribution[star] ?? 0) / total;
  }

  @override
  List<Object?> get props => [average, total, distribution];
}
