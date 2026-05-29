import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Creates an account and returns the authenticated user.
///
/// Backend immediately issues a JWT — no email/SMS confirmation step.
/// KYC photos are uploaded separately, after registration completes.
class RegisterUseCase implements UseCase<AuthUser, RegisterParams> {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(RegisterParams params) {
    return repository.register(
      fullName: params.fullName,
      phone: params.phone,
      nik: params.nik,
      pin: params.pin,
      email: params.email,
      monthlyIncome: params.monthlyIncome,
    );
  }
}

class RegisterParams extends Equatable {
  final String fullName;
  final String phone;
  final String nik;
  final String pin;
  final String? email;
  final int monthlyIncome;

  const RegisterParams({
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
