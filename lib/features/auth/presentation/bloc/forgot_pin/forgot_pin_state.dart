import 'package:equatable/equatable.dart';

/// Linear stages of the forgot-PIN flow.
///
/// `idle` is the resting state at any stage; `loading` indicates a request
/// is in flight. `error` is sticky until the user retries or moves stage.
enum ForgotPinStage { enterIdentifier, enterOtp, enterNewPin, completed }

enum ForgotPinStatus { idle, loading, error }

class ForgotPinState extends Equatable {
  final ForgotPinStage stage;
  final ForgotPinStatus status;
  final String? errorMessage;

  const ForgotPinState({
    this.stage = ForgotPinStage.enterIdentifier,
    this.status = ForgotPinStatus.idle,
    this.errorMessage,
  });

  const ForgotPinState.initial() : this();

  ForgotPinState copyWith({
    ForgotPinStage? stage,
    ForgotPinStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ForgotPinState(
      stage: stage ?? this.stage,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [stage, status, errorMessage];
}
