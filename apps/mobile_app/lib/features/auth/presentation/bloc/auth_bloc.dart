import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/usecases.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC responsible for managing all authentication states and events.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final SocialLoginUseCase _socialLoginUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required LogoutUseCase logoutUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _logoutUseCase = logoutUseCase,
        _socialLoginUseCase = socialLoginUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _refreshTokenUseCase = refreshTokenUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<OtpVerifyRequested>(_onOtpVerifyRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<TokenRefreshRequested>(_onTokenRefreshRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final isAuthResult = await _checkAuthStatusUseCase();
    await isAuthResult.fold(
      (failure) async => emit(const Unauthenticated()),
      (isAuthenticated) async {
        if (!isAuthenticated) {
          emit(const Unauthenticated());
          return;
        }
        final userResult = await _getCurrentUserUseCase();
        // We need token too — refresh to get the current token.
        final tokenResult = await _refreshTokenUseCase();
        userResult.fold(
          (failure) => emit(const Unauthenticated()),
          (user) => tokenResult.fold(
            (failure) => emit(const Unauthenticated()),
            (token) => emit(Authenticated(user: user, token: token)),
          ),
        );
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final tokenResult = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    await tokenResult.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (token) async {
        final userResult = await _getCurrentUserUseCase();
        userResult.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(Authenticated(user: user, token: token)),
        );
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      // After registration, user needs OTP verification.
      (user) => emit(OtpSent(phone: event.phone)),
    );
  }

  Future<void> _onOtpVerifyRequested(
    OtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result =
        await _verifyOtpUseCase(OtpParams(phone: event.phone, otp: event.otp));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (token) => emit(OtpVerified(token: token)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final tokenResult = await _socialLoginUseCase(
      SocialLoginParams(provider: event.provider, token: event.token),
    );
    await tokenResult.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (token) async {
        final userResult = await _getCurrentUserUseCase();
        userResult.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(Authenticated(user: user, token: token)),
        );
      },
    );
  }

  Future<void> _onTokenRefreshRequested(
    TokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _refreshTokenUseCase();
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (_) {
        // Token refreshed silently; no state change needed.
      },
    );
  }
}
