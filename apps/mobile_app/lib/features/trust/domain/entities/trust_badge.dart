import 'package:equatable/equatable.dart';

enum BadgeTier { bronze, silver, gold, platinum }

class TrustBadge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeTier tier;
  final DateTime earnedAt;

  const TrustBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.tier,
    required this.earnedAt,
  });

  @override
  List<Object?> get props =>
      [id, name, description, icon, tier, earnedAt];
}
