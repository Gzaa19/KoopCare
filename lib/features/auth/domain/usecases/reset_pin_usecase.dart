import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Sets a new PIN after the OTP has been verified (forgot-PIN flow).
class ResetPinUseCase implements UseCase<void, ResetPinParams> {
  final AuthRepository repository;

  const ResetPinUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPinParams params) {
    return repository.resetPin(
      identifier: params.identifier,
      otp: params.otp,
      newPin: params.newPin,
    );
  }
}

class ResetPinParams extends Equatable {
  final String identifier;
  final String otp;
  final String newPin;

  const ResetPinParams({
    required this.identifier,
    required this.otp,
    required this.newPin,
  });

  @override
  List<Object?> get props => [identifier, otp, newPin];
}
