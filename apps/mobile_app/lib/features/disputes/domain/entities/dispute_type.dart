enum DisputeType {
  serviceQuality,
  overcharge,
  noShow,
  wrongService,
  damagedProperty,
  unprofessionalBehavior,
  other,
}

extension DisputeTypeExtension on DisputeType {
  String get displayName {
    switch (this) {
      case DisputeType.serviceQuality: return 'Service Quality';
      case DisputeType.overcharge: return 'Overcharge';
      case DisputeType.noShow: return 'No Show';
      case DisputeType.wrongService: return 'Wrong Service';
      case DisputeType.damagedProperty: return 'Damaged Property';
      case DisputeType.unprofessionalBehavior: return 'Unprofessional Behavior';
      case DisputeType.other: return 'Other';
    }
  }
}
