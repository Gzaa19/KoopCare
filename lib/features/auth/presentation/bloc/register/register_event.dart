import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

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

class RegisterReset extends RegisterEvent {
  const RegisterReset();
}
