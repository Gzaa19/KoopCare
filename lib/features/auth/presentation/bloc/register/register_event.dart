import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

/// Submit the full registration form.
///
/// Carries all fields collected across the multi-step UI in one shot —
/// the backend doesn't have intermediate save points.
class RegisterSubmitted extends RegisterEvent {
  final String fullName;
  final String phone;
  final String nik;
  final String pin;
  final String? email;
  final int monthlyIncome;

  const RegisterSubmitted({
    required this.fullName,
    required this.phone,
    required this.nik,
    required this.pin,
    this.email,
    this.monthlyIncome = 0,
  });

  @override
  List<Object?> get props => [fullName, phone, nik, pin, email, monthlyIncome];
}

/// Reset state back to initial — used when user navigates away or wants to
/// retry from scratch.
class RegisterReset extends RegisterEvent {
  const RegisterReset();
}
