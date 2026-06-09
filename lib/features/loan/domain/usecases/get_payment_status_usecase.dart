import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/loan_repository.dart';

class GetPaymentStatusUseCase
    implements UseCase<String, PaymentStatusParams> {
  final LoanRepository repository;
  const GetPaymentStatusUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(PaymentStatusParams params) {
    return repository.getInstallmentPaymentStatus(
        params.loanId, params.installmentId);
  }
}

class PaymentStatusParams extends Equatable {
  final int loanId;
  final int installmentId;

  const PaymentStatusParams({
    required this.loanId,
    required this.installmentId,
  });

  @override
  List<Object?> get props => [loanId, installmentId];
}
