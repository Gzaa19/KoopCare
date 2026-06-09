import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

class GetLoansUseCase implements UseCase<List<Loan>, NoParams> {
  final LoanRepository repository;
  const GetLoansUseCase(this.repository);

  @override
  Future<Either<Failure, List<Loan>>> call(NoParams params) {
    return repository.getMemberLoans();
  }
}
