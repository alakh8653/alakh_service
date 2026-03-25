enum DisputeStatus {
  draft,
  submitted,
  underReview,
  awaitingResponse,
  escalated,
  resolved,
  closed,
}

extension DisputeStatusExtension on DisputeStatus {
  String get displayName {
    switch (this) {
      case DisputeStatus.draft: return 'Draft';
      case DisputeStatus.submitted: return 'Submitted';
      case DisputeStatus.underReview: return 'Under Review';
      case DisputeStatus.awaitingResponse: return 'Awaiting Response';
      case DisputeStatus.escalated: return 'Escalated';
      case DisputeStatus.resolved: return 'Resolved';
      case DisputeStatus.closed: return 'Closed';
    }
  }
}
