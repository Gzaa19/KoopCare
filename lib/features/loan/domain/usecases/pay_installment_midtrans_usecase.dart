import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/loan_repository.dart';

class PayInstallmentMidtransUseCase
    implements UseCase<Map<String, dynamic>, PayMidtransParams> {
  final LoanRepository repository;
  const PayInstallmentMidtransUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      PayMidtransParams params) {
    return repository.payInstallmentViaMidtrans(
        params.loanId, params.installmentId);
  }
}

class PayMidtransParams extends Equatable {
  final int loanId;
  final int installmentId;

  const PayMidtransParams({
    required this.loanId,
    required this.installmentId,
  });

  @override
  List<Object?> get props => [loanId, installmentId];
}
