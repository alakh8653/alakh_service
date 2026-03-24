/// Represents the authentication state of the current user session.
sealed class AuthState {
  const AuthState();

  const factory AuthState.authenticated() = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.loading() = AuthLoading;
}

/// The user has a valid session.
class Authenticated extends AuthState {
  const Authenticated();
}

/// No valid session exists.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Auth check is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}
