import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/register_usecase.dart';
import 'register_event.dart';
import 'register_state.dart';

/// State container for the registration flow.
///
/// Lives separate from `AuthBloc` because the registration state machine
/// (form fields → submitting → success/error) doesn't overlap with the
/// session state machine.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterBloc({required RegisterUseCase registerUseCase})
      : _registerUseCase = registerUseCase,
        super(const RegisterState.initial()) {
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterReset>((_, emit) => emit(const RegisterState.initial()));
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterState.submitting());
    final result = await _registerUseCase(
      RegisterParams(
        fullName: event.fullName,
        phone: event.phone,
        nik: event.nik,
        pin: event.pin,
        email: event.email,
        monthlyIncome: event.monthlyIncome,
      ),
    );
    emit(
      result.fold(
        (failure) => RegisterState.error(failure.message),
        (user) => RegisterState.success(user),
      ),
    );
  }
}
