import 'package:equatable/equatable.dart';
import '../../domain/entities/trust_profile.dart';
import '../../domain/entities/trust_score.dart';
import '../../domain/entities/verification.dart';
import '../../domain/entities/trust_badge.dart';
import '../../domain/entities/safety_report.dart';

abstract class TrustState extends Equatable {
  const TrustState();
  @override
  List<Object?> get props => [];
}

class TrustInitial extends TrustState {
  const TrustInitial();
}

class TrustLoading extends TrustState {
  const TrustLoading();
}

class TrustProfileLoaded extends TrustState {
  final TrustProfile profile;
  const TrustProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class TrustScoreLoaded extends TrustState {
  final TrustScore score;
  const TrustScoreLoaded(this.score);
  @override
  List<Object?> get props => [score];
}

class VerificationsLoaded extends TrustState {
  final List<Verification> verifications;
  const VerificationsLoaded(this.verifications);
  @override
  List<Object?> get props => [verifications];
}

class VerificationStarted extends TrustState {
  final Verification verification;
  const VerificationStarted(this.verification);
  @override
  List<Object?> get props => [verification];
}

class BadgesLoaded extends TrustState {
  final List<TrustBadge> badges;
  const BadgesLoaded(this.badges);
  @override
  List<Object?> get props => [badges];
}

class SafetyReportSubmitted extends TrustState {
  final SafetyReport report;
  const SafetyReportSubmitted(this.report);
  @override
  List<Object?> get props => [report];
}

class TrustError extends TrustState {
  final String message;
  const TrustError(this.message);
  @override
  List<Object?> get props => [message];
}
