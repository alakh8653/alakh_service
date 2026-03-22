import 'package:dartz/dartz.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/failures/failures.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

/// Concrete implementation of [AuthRepository].
///
/// Orchestrates calls to [AuthRemoteDataSource] and [AuthLocalDataSource].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthToken>> login(LoginParams params) async {
    try {
      final request = LoginRequestModel(
        email: params.email,
        password: params.password,
      );
      final tokenModel = await remoteDataSource.login(request);
      await localDataSource.saveToken(tokenModel);
      return Right(tokenModel);
    } on Exception catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, User>> register(RegisterParams params) async {
    try {
      final request = RegisterRequestModel(
        name: params.name,
        email: params.email,
        phone: params.phone,
        password: params.password,
      );
      final userModel = await remoteDataSource.register(request);
      await localDataSource.saveUser(userModel);
      return Right(userModel);
    } on Exception catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> verifyOtp(OtpParams params) async {
    try {
      final request = OtpRequestModel(phone: params.phone, otp: params.otp);
      final tokenModel = await remoteDataSource.verifyOtp(request);
      await localDataSource.saveToken(tokenModel);
      return Right(tokenModel);
    } on Exception catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAll();
      return const Right(unit);
    } on Exception catch (e) {
      // Intentionally clear local session even if the remote logout fails,
      // so the user is always logged out locally (fail-safe logout).
      await localDataSource.clearAll();
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken() async {
    try {
      final currentToken = await localDataSource.getToken();
      if (currentToken == null) {
        return const Left(UnauthorizedFailure('No token found'));
      }
      final newToken =
          await remoteDataSource.refreshToken(currentToken.refreshToken);
      await localDataSource.saveToken(newToken);
      return Right(newToken);
    } on Exception catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> socialLogin(
      SocialLoginParams params) async {
    try {
      final tokenModel =
          await remoteDataSource.socialLogin(params.provider, params.token);
      await localDataSource.saveToken(tokenModel);
      return Right(tokenModel);
    } on Exception catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        return const Left(UnauthorizedFailure('No access token found'));
      }
      final userModel =
          await remoteDataSource.getCurrentUser(token.accessToken);
      await localDataSource.saveUser(userModel);
      return Right(userModel);
    } on Exception catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) return const Right(false);
      return Right(!token.isExpired);
    } on Exception catch (e) {
      return Left(_mapException(e));
    }
  }

  Failure _mapException(Exception e) {
    final message = e.toString();
    if (message.contains('SocketException') ||
        message.contains('NetworkException')) {
      return NetworkFailure('No internet connection: $message');
    }
    if (message.contains('Unauthorized')) {
      return UnauthorizedFailure('Session expired. Please log in again.');
    }
    return ServerFailure('An unexpected error occurred: $message');
  }
}
