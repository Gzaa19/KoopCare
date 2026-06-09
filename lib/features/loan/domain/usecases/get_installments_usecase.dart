import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/installment.dart';
import '../repositories/loan_repository.dart';

class GetInstallmentsUseCase implements UseCase<List<Installment>, int> {
  final LoanRepository repository;
  const GetInstallmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Installment>>> call(int loanId) {
    return repository.getInstallments(loanId);
  }
}
