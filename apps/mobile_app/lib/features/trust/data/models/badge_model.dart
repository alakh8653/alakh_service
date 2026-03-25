import '../../domain/entities/trust_badge.dart';

class BadgeModel extends TrustBadge {
  const BadgeModel({
    required super.id,
    required super.name,
    required super.description,
    required super.icon,
    required super.tier,
    required super.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      tier: BadgeTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => BadgeTier.bronze,
      ),
      earnedAt: DateTime.parse(json['earned_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'tier': tier.name,
        'earned_at': earnedAt.toIso8601String(),
      };
}
