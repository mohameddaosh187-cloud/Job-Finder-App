enum AuthStatus { initial, loading, success, failure }

class AuthState {
  final AuthStatus status;

  const AuthState({this.status = AuthStatus.initial});
}
