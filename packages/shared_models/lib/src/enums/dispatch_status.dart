enum DispatchStatus {
  idle,
  assigned,
  enRoute,
  arrived,
  completed;

  String get displayName {
    switch (this) {
      case DispatchStatus.idle:
        return 'Idle';
      case DispatchStatus.assigned:
        return 'Assigned';
      case DispatchStatus.enRoute:
        return 'En Route';
      case DispatchStatus.arrived:
        return 'Arrived';
      case DispatchStatus.completed:
        return 'Completed';
    }
  }
}
