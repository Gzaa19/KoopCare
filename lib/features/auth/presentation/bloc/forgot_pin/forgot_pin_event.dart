import 'package:equatable/equatable.dart';

abstract class ForgotPinEvent extends Equatable {
  const ForgotPinEvent();

  @override
  List<Object?> get props => [];
}

/// User tapped "Send OTP" — kick off WhatsApp OTP delivery.
class ForgotPinOtpRequested extends ForgotPinEvent {
  final String identifier;

  const ForgotPinOtpRequested(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

/// User entered the 6-digit code — verify it before letting them set a new PIN.
class ForgotPinOtpVerified extends ForgotPinEvent {
  final String identifier;
  final String otp;

  const ForgotPinOtpVerified({required this.identifier, required this.otp});

  @override
  List<Object?> get props => [identifier, otp];
}

/// User submitted a new PIN.
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

/// Reset state back to initial.
class ForgotPinResetState extends ForgotPinEvent {
  const ForgotPinResetState();
}
