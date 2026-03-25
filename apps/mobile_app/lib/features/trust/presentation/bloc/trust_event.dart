import 'package:equatable/equatable.dart';
import '../../domain/entities/verification_type.dart';

abstract class TrustEvent extends Equatable {
  const TrustEvent();
  @override
  List<Object?> get props => [];
}

class LoadTrustProfileEvent extends TrustEvent {
  final String userId;
  const LoadTrustProfileEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class LoadTrustScoreEvent extends TrustEvent {
  final String userId;
  const LoadTrustScoreEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class LoadVerificationsEvent extends TrustEvent {
  final String userId;
  const LoadVerificationsEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class StartVerificationEvent extends TrustEvent {
  final String userId;
  final VerificationType type;
  final List<String> documentUrls;

  const StartVerificationEvent({
    required this.userId,
    required this.type,
    required this.documentUrls,
  });

  @override
  List<Object?> get props => [userId, type, documentUrls];
}

class LoadBadgesEvent extends TrustEvent {
  final String userId;
  const LoadBadgesEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class SubmitSafetyReportEvent extends TrustEvent {
  final String reportedUserId;
  final String type;
  final String description;

  const SubmitSafetyReportEvent({
    required this.reportedUserId,
    required this.type,
    required this.description,
  });

  @override
  List<Object?> get props => [reportedUserId, type, description];
}
