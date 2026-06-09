import 'package:equatable/equatable.dart';

abstract class ForgotPinEvent extends Equatable {
  const ForgotPinEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPinOtpRequested extends ForgotPinEvent {
  final String identifier;

  const ForgotPinOtpRequested(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

class ForgotPinOtpVerified extends ForgotPinEvent {
  final String identifier;
  final String otp;

  const ForgotPinOtpVerified({required this.identifier, required this.otp});

  @override
  List<Object?> get props => [identifier, otp];
}

class ForgotPinReset extends ForgotPinEvent {
  final String identifier;
  final String otp;
  final String newPin;

  const ForgotPinReset({
    required this.identifier,
    required this.otp,
    required this.newPin,
  });

  @override
  List<Object?> get props => [identifier, otp, newPin];
}

class ForgotPinResetState extends ForgotPinEvent {
  const ForgotPinResetState();
}
