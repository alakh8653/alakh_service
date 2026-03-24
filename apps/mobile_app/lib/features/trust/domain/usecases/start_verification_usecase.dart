import 'package:dartz/dartz.dart';
import '../entities/verification.dart';
import '../entities/verification_type.dart';
import '../repositories/trust_repository.dart';

class StartVerificationParams {
  final String userId;
  final VerificationType type;
  final List<String> documentUrls;

  const StartVerificationParams({
    required this.userId,
    required this.type,
    required this.documentUrls,
  });
}

class StartVerificationUsecase {
  final TrustRepository repository;
  const StartVerificationUsecase(this.repository);

  Future<Either<String, Verification>> call(StartVerificationParams params) =>
      repository.startVerification(
        userId: params.userId,
        type: params.type,
        documentUrls: params.documentUrls,
      );
}
