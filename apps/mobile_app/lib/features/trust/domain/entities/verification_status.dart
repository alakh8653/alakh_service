enum VerificationStatus {
  notStarted,
  pending,
  inReview,
  verified,
  expired,
  rejected,
}

extension VerificationStatusExtension on VerificationStatus {
  String get displayName {
    switch (this) {
      case VerificationStatus.notStarted: return 'Not Started';
      case VerificationStatus.pending: return 'Pending';
      case VerificationStatus.inReview: return 'In Review';
      case VerificationStatus.verified: return 'Verified';
      case VerificationStatus.expired: return 'Expired';
      case VerificationStatus.rejected: return 'Rejected';
    }
  }

  bool get isActive => this == VerificationStatus.verified;
}
