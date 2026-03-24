import '../../domain/entities/dispatch_assignment.dart';

/// Data-layer model for [DispatchAssignment] with JSON serialisation support.
class DispatchAssignmentModel extends DispatchAssignment {
  const DispatchAssignmentModel({
    required super.jobId,
    required super.timeout,
    required super.customerName,
    required super.customerPhone,
    required super.serviceType,
    super.serviceDescription,
    required super.estimatedFare,
    required super.pickupAddress,
    required super.dropoffAddress,
  });

  /// Creates a [DispatchAssignmentModel] from a JSON map.
  ///
  /// Expects [timeout_seconds] as an integer.
  factory DispatchAssignmentModel.fromJson(Map<String, dynamic> json) {
    return DispatchAssignmentModel(
      jobId: json['job_id'] as String,
      timeout: Duration(seconds: (json['timeout_seconds'] as num).toInt()),
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      serviceType: json['service_type'] as String,
      serviceDescription: json['service_description'] as String?,
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      dropoffAddress: json['dropoff_address'] as String,
    );
  }

  /// Serialises this model to a JSON map.
  Map<String, dynamic> toJson() => {
        'job_id': jobId,
        'timeout_seconds': timeout.inSeconds,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'service_type': serviceType,
        'service_description': serviceDescription,
        'estimated_fare': estimatedFare,
        'pickup_address': pickupAddress,
        'dropoff_address': dropoffAddress,
      };

  /// Creates a copy with optional field overrides.
  DispatchAssignmentModel copyWith({
    String? jobId,
    Duration? timeout,
    String? customerName,
    String? customerPhone,
    String? serviceType,
    String? serviceDescription,
    double? estimatedFare,
    String? pickupAddress,
    String? dropoffAddress,
  }) {
    return DispatchAssignmentModel(
      jobId: jobId ?? this.jobId,
      timeout: timeout ?? this.timeout,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceType: serviceType ?? this.serviceType,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    );
  }

  /// Creates a [DispatchAssignmentModel] from its domain [DispatchAssignment].
  factory DispatchAssignmentModel.fromEntity(DispatchAssignment entity) {
    return DispatchAssignmentModel(
      jobId: entity.jobId,
      timeout: entity.timeout,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      serviceType: entity.serviceType,
      serviceDescription: entity.serviceDescription,
      estimatedFare: entity.estimatedFare,
      pickupAddress: entity.pickupAddress,
      dropoffAddress: entity.dropoffAddress,
    );
  }
}
