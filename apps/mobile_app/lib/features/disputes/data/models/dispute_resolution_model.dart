import '../../domain/entities/dispute.dart';

class DisputeResolutionModel extends DisputeResolution {
  const DisputeResolutionModel({
    required super.outcome,
    super.refundAmount,
    required super.notes,
    required super.resolvedBy,
  });

  factory DisputeResolutionModel.fromJson(Map<String, dynamic> json) {
    return DisputeResolutionModel(
      outcome: json['outcome'] as String,
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      notes: json['notes'] as String,
      resolvedBy: json['resolved_by'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'outcome': outcome,
        'refund_amount': refundAmount,
        'notes': notes,
        'resolved_by': resolvedBy,
      };
}
