import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Sends an OTP to the user (via WhatsApp) for the forgot-PIN flow.
class RequestOtpUseCase implements UseCase<void, RequestOtpParams> {
  final AuthRepository repository;

  const RequestOtpUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RequestOtpParams params) {
    return repository.requestOtp(params.identifier);
  }
}

class RequestOtpParams extends Equatable {
  final String identifier;

  const RequestOtpParams(this.identifier);

  @override
  List<Object?> get props => [identifier];
}
