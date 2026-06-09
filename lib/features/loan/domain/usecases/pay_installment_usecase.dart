import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/loan_repository.dart';

class PayInstallmentUseCase implements UseCase<void, PayInstallmentParams> {
  final LoanRepository repository;
  const PayInstallmentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PayInstallmentParams params) {
    return repository.payInstallmentFromBalance(
        params.loanId, params.installmentId);
  }
}

class PayInstallmentParams extends Equatable {
  final int loanId;
  final int installmentId;

  const PayInstallmentParams({
    required this.loanId,
    required this.installmentId,
  });

  @override
  List<Object?> get props => [loanId, installmentId];
}
