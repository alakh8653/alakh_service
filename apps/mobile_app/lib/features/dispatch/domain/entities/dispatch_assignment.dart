import 'package:equatable/equatable.dart';

/// Domain entity representing an incoming dispatch assignment offer.
///
/// The staff member must accept or reject before [timeout] expires.
class DispatchAssignment extends Equatable {
  /// Job identifier this assignment refers to.
  final String jobId;

  /// Duration within which the staff must respond.
  final Duration timeout;

  /// Customer's display name.
  final String customerName;

  /// Customer's contact phone number.
  final String customerPhone;

  /// High-level service category (e.g. "Home Cleaning").
  final String serviceType;

  /// Optional additional description of the service required.
  final String? serviceDescription;

  /// Estimated fare for the job.
  final double estimatedFare;

  /// Human-readable pickup address.
  final String pickupAddress;

  /// Human-readable dropoff / service address.
  final String dropoffAddress;

  const DispatchAssignment({
    required this.jobId,
    required this.timeout,
    required this.customerName,
    required this.customerPhone,
    required this.serviceType,
    this.serviceDescription,
    required this.estimatedFare,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  @override
  List<Object?> get props => [
        jobId,
        timeout,
        customerName,
        customerPhone,
        serviceType,
        serviceDescription,
        estimatedFare,
        pickupAddress,
        dropoffAddress,
      ];
}
