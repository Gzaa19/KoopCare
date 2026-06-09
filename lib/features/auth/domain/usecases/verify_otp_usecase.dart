import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<void, VerifyOtpParams> {
  final AuthRepository repository;

  const VerifyOtpUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyOtpParams params) {
    return repository.verifyOtp(identifier: params.identifier, otp: params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String identifier;
  final String otp;

  const VerifyOtpParams({required this.identifier, required this.otp});

  @override
  List<Object?> get props => [identifier, otp];
}
