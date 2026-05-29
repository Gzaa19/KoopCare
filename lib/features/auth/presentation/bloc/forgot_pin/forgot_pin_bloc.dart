import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/request_otp_usecase.dart';
import '../../../domain/usecases/reset_pin_usecase.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import 'forgot_pin_event.dart';
import 'forgot_pin_state.dart';

/// Drives the forgot-PIN flow: identifier → OTP → new PIN.
///
/// The legacy backend re-verifies the OTP during `resetPin`, so the explicit
/// verify step is technically optional. We keep it here because the UI uses
/// it as a UX gate (prove OTP correct before showing the new-PIN screen).
class ForgotPinBloc extends Bloc<ForgotPinEvent, ForgotPinState> {
  final RequestOtpUseCase _requestOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResetPinUseCase _resetPinUseCase;

  ForgotPinBloc({
    required RequestOtpUseCase requestOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ResetPinUseCase resetPinUseCase,
  })  : _requestOtpUseCase = requestOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _resetPinUseCase = resetPinUseCase,
        super(const ForgotPinState.initial()) {
    on<ForgotPinOtpRequested>(_onOtpRequested);
    on<ForgotPinOtpVerified>(_onOtpVerified);
    on<ForgotPinReset>(_onReset);
    on<ForgotPinResetState>(
      (_, emit) => emit(const ForgotPinState.initial()),
    );
  }

  Future<void> _onOtpRequested(
    ForgotPinOtpRequested event,
    Emitter<ForgotPinState> emit,
  ) async {
    emit(state.copyWith(status: ForgotPinStatus.loading, clearError: true));
    final result = await _requestOtpUseCase(RequestOtpParams(event.identifier));
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: ForgotPinStatus.error,
          errorMessage: failure.message,
        ),
        (_) => state.copyWith(
          stage: ForgotPinStage.enterOtp,
          status: ForgotPinStatus.idle,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onOtpVerified(
    ForgotPinOtpVerified event,
    Emitter<ForgotPinState> emit,
  ) async {
    emit(state.copyWith(status: ForgotPinStatus.loading, clearError: true));
    final result = await _verifyOtpUseCase(
      VerifyOtpParams(identifier: event.identifier, otp: event.otp),
    );
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: ForgotPinStatus.error,
          errorMessage: failure.message,
        ),
        (_) => state.copyWith(
          stage: ForgotPinStage.enterNewPin,
          status: ForgotPinStatus.idle,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onReset(
    ForgotPinReset event,
    Emitter<ForgotPinState> emit,
  ) async {
    emit(state.copyWith(status: ForgotPinStatus.loading, clearError: true));
    final result = await _resetPinUseCase(
      ResetPinParams(
        identifier: event.identifier,
        otp: event.otp,
        newPin: event.newPin,
      ),
    );
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: ForgotPinStatus.error,
          errorMessage: failure.message,
        ),
        (_) => state.copyWith(
          stage: ForgotPinStage.completed,
          status: ForgotPinStatus.idle,
          clearError: true,
        ),
      ),
    );
  }
}
