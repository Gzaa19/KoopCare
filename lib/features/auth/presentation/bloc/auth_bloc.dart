import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository authRepository,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _authRepository = authRepository,
       super(const AuthState.initial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserRestoreRequested>(_onUserRestoreRequested);
    on<AuthProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _loginUseCase(
      LoginParams(identifier: event.identifier, pin: event.pin),
    );
    emit(
      result.fold(
        (failure) => AuthState.error(failure.message),
        (user) => AuthState.authenticated(user),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _logoutUseCase(const NoParams());
    emit(
      result.fold(
        (failure) => AuthState.error(failure.message),
        (_) => const AuthState.unauthenticated(),
      ),
    );
  }

  Future<void> _onUserRestoreRequested(
    AuthUserRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    final cached = await _authRepository.getCachedUser();
    if (cached != null) {
      emit(AuthState.authenticated(cached));
    }
  }

  Future<void> _onProfileRefreshRequested(
    AuthProfileRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.refreshProfile();
    result.fold(
      (_) {},
      (user) => emit(AuthState.authenticated(user)),
    );
  }
}
