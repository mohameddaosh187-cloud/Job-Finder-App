import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job_finder/features/auth/data/firebase/auth_service.dart';
import 'package:job_finder/features/auth/data/model/user_model.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(const AuthState());

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) => _run(() => _authService.signIn(email: email, password: password));

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) => _run(
    () => _authService.signUp(
      fullName: fullName,
      email: email,
      password: password,
    ),
  );

  Future<UserModel> _run(Future<UserModel> Function() action) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final user = await action();
      emit(const AuthState(status: AuthStatus.success));
      return user;
    } catch (_) {
      emit(const AuthState(status: AuthStatus.failure));
      rethrow;
    }
  }
}
