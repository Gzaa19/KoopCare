import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/installment.dart';
import '../entities/loan.dart';

abstract class LoanRepository {
  Future<Either<Failure, List<Loan>>> getMemberLoans();

  Future<Either<Failure, List<Installment>>> getInstallments(int loanId);

  Future<Either<Failure, void>> payInstallmentFromBalance(
      int loanId, int installmentId);

  Future<Either<Failure, Map<String, dynamic>>> payInstallmentViaMidtrans(
      int loanId, int installmentId);

  Future<Either<Failure, String>> getInstallmentPaymentStatus(
      int loanId, int installmentId);
}
