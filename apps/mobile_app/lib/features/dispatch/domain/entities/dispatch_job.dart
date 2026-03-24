import 'package:equatable/equatable.dart';
import 'dispatch_location.dart';
import 'dispatch_status.dart';

/// Domain entity representing a dispatch job assigned to a service staff member.
class DispatchJob extends Equatable {
  /// Unique job identifier.
  final String id;

  /// Booking reference this job is linked to.
  final String bookingId;

  /// ID of the staff member the job is assigned to.
  final String staffId;

  /// ID of the customer requesting the service.
  final String customerId;

  /// Current lifecycle status of this job.
  final DispatchStatus status;

  /// Location where the staff should pick up / meet the customer.
  final DispatchLocation pickupLocation;

  /// Final service or drop-off location.
  final DispatchLocation dropoffLocation;

  /// Road distance in kilometres between pickup and dropoff.
  final double distance;

  /// Estimated duration to complete the job.
  final Duration estimatedDuration;

  /// Agreed fare for this job in the app's base currency.
  final double fare;

  /// Optional free-text notes for the job.
  final String? notes;

  /// UTC timestamp when this job was created.
  final DateTime createdAt;

  const DispatchJob({
    required this.id,
    required this.bookingId,
    required this.staffId,
    required this.customerId,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.distance,
    required this.estimatedDuration,
    required this.fare,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        staffId,
        customerId,
        status,
        pickupLocation,
        dropoffLocation,
        distance,
        estimatedDuration,
        fare,
        notes,
        createdAt,
      ];
}
